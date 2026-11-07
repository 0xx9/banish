import Foundation

public struct AppScanner: Sendable {
    public init() {}

    public func scan(_ locations: ScanLocations) -> ScanResult {
        var found: [String: InstalledApp] = [:]
        var unreadable: [String] = []
        let fileManager = FileManager()

        for directory in locations.applicationDirectories {
            let root = URL(fileURLWithPath: directory)
            var isDirectory = ObjCBool(false)
            guard fileManager.fileExists(atPath: root.path, isDirectory: &isDirectory), isDirectory.boolValue else {
                continue
            }
            switch list(root) {
            case .missing:
                continue
            case .denied:
                unreadable.append(root.path)
            case .items(let children):
                collect(
                    children,
                    depth: 0,
                    maximumDepth: locations.maximumDepth,
                    locations: locations,
                    into: &found
                )
            }
        }

        let apps = found.values.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        return ScanResult(apps: apps, unreadableDirectories: unreadable)
    }

    private func collect(
        _ urls: [URL],
        depth: Int,
        maximumDepth: Int,
        locations: ScanLocations,
        into found: inout [String: InstalledApp]
    ) {
        for url in urls {
            if isSymbolicLink(url) {
                continue
            }
            if isAppBundle(url) {
                if let app = readApp(at: url, locations: locations) {
                    let key = PathSafety.lexical(app.path).lowercased()
                    found[key] = app
                }
                continue
            }
            guard depth + 1 < maximumDepth, isDirectory(url), !isPackage(url) else { continue }
            if case .items(let children) = list(url) {
                collect(
                    children,
                    depth: depth + 1,
                    maximumDepth: maximumDepth,
                    locations: locations,
                    into: &found
                )
            }
        }
    }

    private func readApp(at url: URL, locations: ScanLocations) -> InstalledApp? {
        let infoURL = url.appendingPathComponent("Contents/Info.plist")
        guard let info = readPlist(infoURL) else { return nil }

        let fileName = url.deletingPathExtension().lastPathComponent
        let bundleName = string(info, "CFBundleName")
        let displayName = string(info, "CFBundleDisplayName")
        let localized = localizedName(appURL: url)
        let name = localized ?? displayName ?? bundleName ?? fileName
        let bundleID = string(info, "CFBundleIdentifier") ?? ""
        let executable = string(info, "CFBundleExecutable") ?? fileName
        let version = string(info, "CFBundleShortVersionString") ?? string(info, "CFBundleVersion") ?? ""
        var names = [fileName, name, bundleName, displayName, localized, executable].compactMap { $0 }
        names = unique(names)

        var associated = associatedBundleIDs(appURL: url, mainID: bundleID)
        if !bundleID.lowercased().hasPrefix("com.apple.") {
            associated.removeAll { $0.lowercased().hasPrefix("com.apple.") }
        }

        return InstalledApp(
            name: name,
            bundleIdentifier: bundleID,
            version: version,
            path: url.path,
            executableName: executable,
            matchNames: names,
            associatedBundleIdentifiers: associated,
            protectionReason: protection(path: url.path, bundleID: bundleID, locations: locations)
        )
    }

    private func protection(path: String, bundleID: String, locations: ScanLocations) -> ProtectionReason? {
        let identifier = bundleID.lowercased()
        if identifier == "com.cliner.app" {
            return .currentApplication
        }
        if let current = locations.currentApplicationPath, PathSafety.sameFile(path, current) {
            return .currentApplication
        }
        if locations.protectedPathPrefixes.contains(where: { PathSafety.hasPrefix(path, $0) }) {
            return .systemLocation
        }
        if criticalBundleIDs.contains(identifier) {
            return .criticalAppleApp
        }
        return nil
    }

    private func associatedBundleIDs(appURL: URL, mainID: String) -> [String] {
        var identifiers: [String] = []
        let relativeDirectories = [
            "Contents/XPCServices",
            "Contents/PlugIns",
            "Contents/Library/LoginItems"
        ]
        for relative in relativeDirectories {
            let directory = appURL.appendingPathComponent(relative)
            guard case .items(let children) = list(directory) else { continue }
            for child in children {
                let ext = child.pathExtension.lowercased()
                guard ["xpc", "appex", "bundle", "app", "plugin"].contains(ext) else { continue }
                let plist = child.appendingPathComponent("Contents/Info.plist")
                if let identifier = readPlist(plist).flatMap({ string($0, "CFBundleIdentifier") }),
                   identifier.caseInsensitiveCompare(mainID) != .orderedSame {
                    identifiers.append(identifier)
                }
            }
        }

        let agents = appURL.appendingPathComponent("Contents/Library/LaunchAgents")
        if case .items(let children) = list(agents) {
            for child in children where child.pathExtension.lowercased() == "plist" {
                if let label = readPlist(child).flatMap({ string($0, "Label") }), label.contains(".") {
                    identifiers.append(label)
                }
            }
        }

        return unique(identifiers).sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    private func localizedName(appURL: URL) -> String? {
        var languages: [String] = []
        for language in Locale.preferredLanguages {
            let underscored = language.replacingOccurrences(of: "-", with: "_")
            languages.append(underscored)
            languages.append(String(language.prefix(2)))
        }
        var seen = Set<String>()
        for language in languages where seen.insert(language).inserted {
            let url = appURL.appendingPathComponent("Contents/Resources/\(language).lproj/InfoPlist.strings")
            guard let info = readPlist(url) else { continue }
            if let name = string(info, "CFBundleDisplayName") ?? string(info, "CFBundleName"), !name.isEmpty {
                return name
            }
        }
        return nil
    }

    private func isAppBundle(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == "app" && isDirectory(url)
    }

    private func isPackage(_ url: URL) -> Bool {
        if let values = try? url.resourceValues(forKeys: [.isPackageKey]), values.isPackage == true {
            return true
        }
        let ext = url.pathExtension.lowercased()
        return ["app", "bundle", "framework", "plugin", "kext", "photoslibrary"].contains(ext)
    }

    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        return FileManager().fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func isSymbolicLink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink == true
    }

    private enum ListResult {
        case missing
        case denied
        case items([URL])
    }

    private func list(_ url: URL) -> ListResult {
        let fileManager = FileManager()
        var isDirectory = ObjCBool(false)
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else { return .missing }
        guard isDirectory.boolValue else { return .missing }
        do {
            let children = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .isPackageKey],
                options: [.skipsHiddenFiles]
            )
            return .items(children)
        } catch let error as NSError {
            if error.domain == CocoaError.errorDomain && error.code == CocoaError.fileReadNoSuchFile.rawValue {
                return .missing
            }
            return .denied
        }
    }

    private func readPlist(_ url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
    }

    private func string(_ info: [String: Any], _ key: String) -> String? {
        guard let value = info[key] as? String else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for value in values {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, seen.insert(trimmed.lowercased()).inserted else { continue }
            result.append(trimmed)
        }
        return result
    }

    private let criticalBundleIDs: Set<String> = [
        "com.apple.finder",
        "com.apple.dock",
        "com.apple.loginwindow",
        "com.apple.systempreferences",
        "com.apple.settings",
        "com.apple.controlcenter",
        "com.apple.notificationcenterui",
        "com.apple.securityagent",
        "com.apple.safari",
        "com.apple.mail",
        "com.apple.mobilesms",
        "com.apple.mobilemail",
        "com.apple.photos",
        "com.apple.facetime",
        "com.apple.ical",
        "com.apple.addressbook",
        "com.apple.notes",
        "com.apple.reminders",
        "com.apple.maps",
        "com.apple.appstore",
        "com.apple.music",
        "com.apple.tv",
        "com.apple.preview",
        "com.apple.textedit",
        "com.apple.terminal",
        "com.apple.activitymonitor",
        "com.apple.systemprofiler",
        "com.apple.dictionary",
        "com.apple.calculator",
        "com.apple.spotlight",
        "com.apple.siri",
        "com.apple.home",
        "com.apple.weather",
        "com.apple.stocks",
        "com.apple.news",
        "com.apple.podcasts",
        "com.apple.shortcuts",
        "com.apple.freeform",
        "com.apple.journal",
        "com.apple.passbook"
    ]
}
