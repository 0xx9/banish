import Foundation

public struct LeftoverFinder: Sendable {
    public var scope: LeftoverSearchScope

    public init(scope: LeftoverSearchScope) {
        self.scope = scope
    }

    public func find(for fingerprint: AppFingerprint) -> LeftoverScan {
        let query = MatchQuery.make(from: fingerprint)
        let policy = DeletionPolicy(userHome: homePath)
        var found: [String: LeftoverMatch] = [:]
        var denied: [String] = []

        for root in roots() {
            search(
                root: root,
                fingerprint: fingerprint,
                query: query,
                policy: policy,
                into: &found,
                denied: &denied
            )
        }

        let items = found.values.sorted { lhs, rhs in
            if lhs.category.sortIndex != rhs.category.sortIndex {
                return lhs.category.sortIndex < rhs.category.sortIndex
            }
            return lhs.path.localizedStandardCompare(rhs.path) == .orderedAscending
        }
        return LeftoverScan(items: items, accessDenied: unique(denied))
    }

    private struct SearchRoot {
        var url: URL
        var category: LeftoverCategory
        var depth: Int
        var mode: SearchMode
    }

    private enum SearchMode {
        case bundleOnly
        case bundleOrName
        case launchAgent
    }

    private func roots() -> [SearchRoot] {
        var result: [SearchRoot] = []
        result.append(contentsOf: libraryRoots(scope.userLibrary, includeUserOnly: true))
        for library in scope.additionalLibraries {
            result.append(contentsOf: libraryRoots(library, includeUserOnly: false))
        }
        return result
    }

    private func libraryRoots(_ library: String, includeUserOnly: Bool) -> [SearchRoot] {
        func url(_ relative: String) -> URL {
            URL(fileURLWithPath: library).appendingPathComponent(relative)
        }
        var roots = [
            SearchRoot(url: url("Application Support"), category: .applicationSupport, depth: 2, mode: .bundleOrName),
            SearchRoot(url: url("Caches"), category: .caches, depth: 1, mode: .bundleOrName),
            SearchRoot(url: url("Preferences"), category: .preferences, depth: 1, mode: .bundleOnly),
            SearchRoot(url: url("Preferences/ByHost"), category: .preferences, depth: 1, mode: .bundleOnly),
            SearchRoot(url: url("Logs"), category: .logs, depth: 1, mode: .bundleOrName),
            SearchRoot(url: url("LaunchAgents"), category: .launchAgents, depth: 1, mode: .launchAgent),
            SearchRoot(url: url("LaunchDaemons"), category: .launchDaemons, depth: 1, mode: .launchAgent),
            SearchRoot(url: url("Developer"), category: .developer, depth: 2, mode: .bundleOrName)
        ]
        if includeUserOnly {
            roots.append(contentsOf: [
                SearchRoot(url: url("Saved Application State"), category: .savedState, depth: 1, mode: .bundleOnly),
                SearchRoot(url: url("Containers"), category: .containers, depth: 1, mode: .bundleOnly),
                SearchRoot(url: url("Group Containers"), category: .groupContainers, depth: 1, mode: .bundleOnly),
                SearchRoot(url: url("HTTPStorages"), category: .webData, depth: 1, mode: .bundleOnly),
                SearchRoot(url: url("WebKit"), category: .webData, depth: 1, mode: .bundleOnly),
                SearchRoot(url: url("Cookies"), category: .webData, depth: 1, mode: .bundleOnly),
                SearchRoot(url: url("Application Scripts"), category: .scripts, depth: 1, mode: .bundleOnly)
            ])
        }
        return roots
    }

    private func search(
        root: SearchRoot,
        fingerprint: AppFingerprint,
        query: MatchQuery,
        policy: DeletionPolicy,
        into found: inout [String: LeftoverMatch],
        denied: inout [String]
    ) {
        switch list(root.url) {
        case .missing:
            return
        case .denied:
            if isUserLibraryPath(root.url.path) {
                denied.append(root.url.path)
            }
        case .items(let children):
            for child in children {
                if isSymbolicLink(child) { continue }
                if root.mode == .launchAgent {
                    if let reason = launchAgentReason(at: child, fingerprint: fingerprint) {
                        add(child, category: root.category, reason: reason, fingerprint: fingerprint, policy: policy, into: &found)
                    }
                    continue
                }
                if let reason = match(name: child.lastPathComponent, parent: nil, mode: root.mode, query: query) {
                    add(child, category: root.category, reason: reason, fingerprint: fingerprint, policy: policy, into: &found)
                    continue
                }
                guard root.depth >= 2, isDirectory(child), !isPackage(child) else { continue }
                if case .items(let grandchildren) = list(child) {
                    for grandchild in grandchildren {
                        if isSymbolicLink(grandchild) { continue }
                        if let reason = match(
                            name: grandchild.lastPathComponent,
                            parent: child.lastPathComponent,
                            mode: root.mode,
                            query: query
                        ) {
                            add(
                                grandchild,
                                category: root.category,
                                reason: reason,
                                fingerprint: fingerprint,
                                policy: policy,
                                into: &found
                            )
                        }
                    }
                }
            }
        }
    }

    private func match(name: String, parent: String?, mode: SearchMode, query: MatchQuery) -> MatchReason? {
        for identifier in query.bundleIdentifiers where Matcher.matchesBundleID(entryName: name, bundleID: identifier) {
            return .bundleIdentifier
        }
        guard mode == .bundleOrName else { return nil }
        if let parent {
            return Matcher.matchCompanyProduct(child: name, parent: parent, query: query)
        }
        return Matcher.matchExactName(name, query: query)
    }

    private func launchAgentReason(at url: URL, fingerprint: AppFingerprint) -> MatchReason? {
        guard url.pathExtension.lowercased() == "plist" else { return nil }
        guard let info = readPlist(url) else { return nil }
        if let label = info["Label"] as? String {
            for identifier in fingerprint.bundleIdentifiers where Matcher.matchesBundleID(entryName: label, bundleID: identifier) {
                return .bundleIdentifier
            }
        }
        var programs: [String] = []
        if let program = info["Program"] as? String {
            programs.append(program)
        }
        if let arguments = info["ProgramArguments"] as? [String] {
            programs.append(contentsOf: arguments)
        }
        let appPath = fingerprint.bundlePath.lowercased()
        guard !appPath.isEmpty else { return nil }
        for program in programs {
            let candidate = program.lowercased()
            if candidate == appPath || candidate.hasPrefix(appPath + "/") {
                return .launchAgentProgram
            }
        }
        return nil
    }

    private func add(
        _ url: URL,
        category: LeftoverCategory,
        reason: MatchReason,
        fingerprint: AppFingerprint,
        policy: DeletionPolicy,
        into found: inout [String: LeftoverMatch]
    ) {
        let path = url.path
        if PathSafety.sameFile(path, fingerprint.bundlePath) || PathSafety.isStrictlyInside(path, fingerprint.bundlePath) {
            return
        }
        if policy.isSensitive(path) {
            return
        }
        let key = PathSafety.lexical(path).lowercased()
        if let existing = found[key] {
            if existing.reason.isStrong || !reason.isStrong {
                return
            }
        }
        found[key] = LeftoverMatch(
            path: path,
            name: url.lastPathComponent,
            category: category,
            reason: reason
        )
    }

    private var homePath: String {
        let library = PathSafety.lexical(scope.userLibrary)
        let suffix = "/Library"
        if library.lowercased().hasSuffix(suffix.lowercased()) {
            return String(library.dropLast(suffix.count))
        }
        return library
    }

    private func isUserLibraryPath(_ path: String) -> Bool {
        PathSafety.hasPrefix(path, scope.userLibrary)
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

    private func isDirectory(_ url: URL) -> Bool {
        var isDirectory = ObjCBool(false)
        return FileManager().fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func isPackage(_ url: URL) -> Bool {
        if (try? url.resourceValues(forKeys: [.isPackageKey]))?.isPackage == true {
            return true
        }
        return ["app", "bundle", "framework", "plugin"].contains(url.pathExtension.lowercased())
    }

    private func isSymbolicLink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]))?.isSymbolicLink == true
    }

    private func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for value in values where seen.insert(PathSafety.lexical(value).lowercased()).inserted {
            result.append(value)
        }
        return result
    }
}
