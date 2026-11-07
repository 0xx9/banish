import Foundation

/// Decides whether a path may be moved to the Trash.
/// Related files must live under a Library folder. Application bundles must live
/// in /Applications or the user Applications folder. System locations, personal
/// data, and Apple files that do not belong to the selected app are refused.
public struct DeletionPolicy: Sendable {
    public let userHome: String

    public init(userHome: String) {
        self.userHome = PathSafety.lexical(userHome)
    }

    public func rejectionReason(
        for item: TrashItem,
        authorization: TrashAuthorization
    ) -> RejectionReason? {
        if PathSafety.containsTraversal(item.path) || !PathSafety.isAbsolute(item.path) {
            return .escapesRoot
        }
        let path = PathSafety.lexical(item.path)
        if !isPermitted(path, authorization) {
            return .notPermitted
        }
        if let current = authorization.currentApplicationPath, PathSafety.sameFile(path, current) {
            return .currentApplication
        }
        if let structural = structuralRejection(path, kind: item.kind, authorization: authorization) {
            return structural
        }
        if isSymbolicLink(path) {
            return .escapesRoot
        }
        return nil
    }

    public func isSensitive(_ path: String) -> Bool {
        for relative in sensitiveRelativePaths {
            if PathSafety.hasPrefix(path, userHome + "/" + relative) {
                return true
            }
        }
        return PathSafety.hasPrefix(path, "/Library/Keychains")
    }

    private func isPermitted(_ path: String, _ authorization: TrashAuthorization) -> Bool {
        authorization.permittedPaths.contains { PathSafety.sameFile($0, path) }
    }

    private func structuralRejection(
        _ path: String,
        kind: TrashItemKind,
        authorization: TrashAuthorization
    ) -> RejectionReason? {
        if isSystemLocation(path) {
            return .systemLocation
        }
        if isSensitive(path) {
            return .sensitiveLocation
        }
        switch kind {
        case .applicationBundle:
            guard path.lowercased().hasSuffix(".app") else { return .notAnApplicationBundle }
            guard isAcceptedApplicationLocation(path) else { return .unexpectedApplicationLocation }
            guard isInsideAllowedRoot(path) else { return .outsideAllowedRoots }
        case .relatedFile:
            guard isUnderLibrary(path) else { return .outsideAllowedRoots }
            guard libraryDepth(path) >= 2 else { return .pathTooShallow }
            if hasUnrelatedAppleIdentifier(path, authorization) {
                return .unrelatedAppleFile
            }
        }
        return nil
    }

    private func isSystemLocation(_ path: String) -> Bool {
        let lexical = PathSafety.lexical(path)
        if lexical.caseInsensitiveCompare(userHome) == .orderedSame || PathSafety.isStrictlyInside(path, userHome) {
            return false
        }
        return systemRoots.contains { PathSafety.hasPrefix(path, $0) }
    }

    private func isInsideAllowedRoot(_ path: String) -> Bool {
        allowedRoots.contains { PathSafety.isStrictlyInside(path, $0) }
    }

    private func isUnderLibrary(_ path: String) -> Bool {
        PathSafety.isStrictlyInside(path, userHome + "/Library") || PathSafety.isStrictlyInside(path, "/Library")
    }

    private func isAcceptedApplicationLocation(_ path: String) -> Bool {
        guard PathSafety.lexical(path).lowercased().hasSuffix(".app") else { return false }
        let parent = URL(fileURLWithPath: PathSafety.lexical(path)).deletingLastPathComponent().path
        let grandparent = URL(fileURLWithPath: parent).deletingLastPathComponent().path
        return applicationRoots.contains { root in
            let lexicalRoot = PathSafety.lexical(root)
            return lexicalRoot.caseInsensitiveCompare(parent) == .orderedSame
                || lexicalRoot.caseInsensitiveCompare(grandparent) == .orderedSame
        }
    }

    private func libraryDepth(_ path: String) -> Int {
        let roots = [userHome + "/Library", "/Library"]
        for root in roots where PathSafety.isStrictlyInside(path, root) {
            let base = PathSafety.lexical(root)
            let full = PathSafety.lexical(path)
            let relative = full.dropFirst(base.count)
            return relative.split(separator: "/").filter { !$0.isEmpty }.count
        }
        return 0
    }

    private func hasUnrelatedAppleIdentifier(_ path: String, _ authorization: TrashAuthorization) -> Bool {
        let parts = PathSafety.lexical(path).split(separator: "/").map(String.init)
        let appleParts = parts.filter { $0.lowercased().contains("com.apple.") }
        guard !appleParts.isEmpty else { return false }
        let appleIDs = authorization.bundleIdentifiers.filter { $0.lowercased().hasPrefix("com.apple.") }
        guard !appleIDs.isEmpty else { return true }
        return !appleParts.allSatisfy { part in
            appleIDs.contains { Matcher.matchesBundleID(entryName: part, bundleID: $0) }
        }
    }

    private func isSymbolicLink(_ path: String) -> Bool {
        let values = try? URL(fileURLWithPath: path).resourceValues(forKeys: [.isSymbolicLinkKey])
        return values?.isSymbolicLink == true
    }

    private var allowedRoots: [String] {
        [userHome + "/Library", userHome + "/Applications", "/Applications", "/Library"]
    }

    private var applicationRoots: [String] {
        [userHome + "/Applications", "/Applications"]
    }

    private let systemRoots = [
        "/system", "/usr", "/bin", "/sbin", "/etc", "/private", "/var",
        "/volumes", "/dev", "/opt", "/cores", "/tmp"
    ]

    private let sensitiveRelativePaths = [
        "Library/Mail",
        "Library/Messages",
        "Library/Keychains",
        "Library/Safari",
        "Library/Accounts",
        "Library/IdentityServices",
        "Library/HomeKit",
        "Library/Calendars",
        "Library/Reminders",
        "Library/Photos",
        "Library/Biome",
        "Library/PersonalizationPortrait",
        "Library/Mobile Documents",
        "Library/CloudStorage",
        "Library/DoNotDisturb",
        "Library/StatusKit",
        "Library/Suggestions",
        "Library/IntelligencePlatform",
        "Library/Trial",
        "Library/Metadata/CoreSpotlight",
        "Library/Finance",
        "Library/Containers/com.apple.mail",
        "Library/Containers/com.apple.Safari",
        "Library/Containers/com.apple.MobileSMS",
        "Library/Containers/com.apple.cloudDocs",
        "Library/Containers/com.apple.Notes",
        "Library/Containers/com.apple.Photos",
        "Library/Group Containers/group.com.apple.mail",
        "Library/Group Containers/group.com.apple.notes",
        "Documents",
        "Desktop",
        "Downloads",
        "Pictures",
        "Movies",
        "Music",
        "Public",
        ".ssh",
        ".Trash"
    ]
}
