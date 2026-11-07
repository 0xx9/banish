import Foundation

public enum ProtectionReason: String, Sendable, Equatable, Hashable {
    case systemLocation
    case criticalAppleApp
    case currentApplication
}

public struct InstalledApp: Identifiable, Sendable, Equatable, Hashable {
    public var id: String { path }
    public var name: String
    public var bundleIdentifier: String
    public var version: String
    public var path: String
    public var executableName: String
    public var matchNames: [String]
    public var associatedBundleIdentifiers: [String]
    public var sizeBytes: Int64?
    public var protectionReason: ProtectionReason?

    public var isProtected: Bool { protectionReason != nil }

    public var isAppleApp: Bool {
        bundleIdentifier.lowercased().hasPrefix("com.apple.")
    }

    public var fingerprint: AppFingerprint {
        AppFingerprint(
            displayName: name,
            bundleIdentifier: bundleIdentifier,
            executableName: executableName,
            matchNames: matchNames,
            associatedBundleIdentifiers: associatedBundleIdentifiers,
            bundlePath: path
        )
    }

    public init(
        name: String,
        bundleIdentifier: String,
        version: String,
        path: String,
        executableName: String,
        matchNames: [String],
        associatedBundleIdentifiers: [String],
        sizeBytes: Int64? = nil,
        protectionReason: ProtectionReason? = nil
    ) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.path = path
        self.executableName = executableName
        self.matchNames = matchNames
        self.associatedBundleIdentifiers = associatedBundleIdentifiers
        self.sizeBytes = sizeBytes
        self.protectionReason = protectionReason
    }
}

public struct AppFingerprint: Sendable, Equatable, Hashable {
    public var displayName: String
    public var bundleIdentifier: String
    public var executableName: String
    public var matchNames: [String]
    public var associatedBundleIdentifiers: [String]
    public var bundlePath: String

    public init(
        displayName: String,
        bundleIdentifier: String,
        executableName: String,
        matchNames: [String],
        associatedBundleIdentifiers: [String],
        bundlePath: String
    ) {
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
        self.executableName = executableName
        self.matchNames = matchNames
        self.associatedBundleIdentifiers = associatedBundleIdentifiers
        self.bundlePath = bundlePath
    }

    public var bundleIdentifiers: [String] {
        var seen = Set<String>()
        var result: [String] = []
        for identifier in [bundleIdentifier] + associatedBundleIdentifiers {
            let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
            let key = trimmed.lowercased()
            guard trimmed.contains("."), seen.insert(key).inserted else { continue }
            result.append(trimmed)
        }
        return result
    }
}

public enum MatchReason: String, Sendable, Equatable, Hashable {
    case bundleIdentifier
    case launchAgentProgram
    case exactName
    case companyProduct

    public var isStrong: Bool {
        switch self {
        case .bundleIdentifier, .launchAgentProgram:
            return true
        case .exactName, .companyProduct:
            return false
        }
    }
}

public enum LeftoverCategory: String, Sendable, Equatable, Hashable, CaseIterable {
    case applicationSupport
    case caches
    case preferences
    case logs
    case savedState
    case containers
    case groupContainers
    case webData
    case launchAgents
    case launchDaemons
    case scripts
    case developer

    public var sortIndex: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

public struct LeftoverMatch: Identifiable, Sendable, Equatable, Hashable {
    public var id: String { path }
    public var path: String
    public var name: String
    public var category: LeftoverCategory
    public var reason: MatchReason
    public var sizeBytes: Int64?

    public init(
        path: String,
        name: String,
        category: LeftoverCategory,
        reason: MatchReason,
        sizeBytes: Int64? = nil
    ) {
        self.path = path
        self.name = name
        self.category = category
        self.reason = reason
        self.sizeBytes = sizeBytes
    }
}

public struct LeftoverScan: Sendable, Equatable {
    public var items: [LeftoverMatch]
    public var accessDenied: [String]

    public init(items: [LeftoverMatch], accessDenied: [String]) {
        self.items = items
        self.accessDenied = accessDenied
    }
}

public struct ScanLocations: Sendable, Equatable {
    public var applicationDirectories: [String]
    public var maximumDepth: Int
    public var currentApplicationPath: String?
    public var protectedPathPrefixes: [String]

    public init(
        applicationDirectories: [String],
        maximumDepth: Int = 2,
        currentApplicationPath: String? = nil,
        protectedPathPrefixes: [String] = ["/System"]
    ) {
        self.applicationDirectories = applicationDirectories
        self.maximumDepth = maximumDepth
        self.currentApplicationPath = currentApplicationPath
        self.protectedPathPrefixes = protectedPathPrefixes
    }

    public static func systemDefault(currentApplicationPath: String?) -> ScanLocations {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return ScanLocations(
            applicationDirectories: [
                "/Applications",
                "/System/Applications",
                home + "/Applications"
            ],
            maximumDepth: 2,
            currentApplicationPath: currentApplicationPath,
            protectedPathPrefixes: ["/System"]
        )
    }
}

public struct ScanResult: Sendable, Equatable {
    public var apps: [InstalledApp]
    public var unreadableDirectories: [String]

    public init(apps: [InstalledApp], unreadableDirectories: [String]) {
        self.apps = apps
        self.unreadableDirectories = unreadableDirectories
    }
}

public struct LeftoverSearchScope: Sendable, Equatable {
    public var userLibrary: String
    public var additionalLibraries: [String]

    public init(userLibrary: String, additionalLibraries: [String] = []) {
        self.userLibrary = userLibrary
        self.additionalLibraries = additionalLibraries
    }

    public static func systemDefault() -> LeftoverSearchScope {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return LeftoverSearchScope(
            userLibrary: home + "/Library",
            additionalLibraries: ["/Library"]
        )
    }
}

public enum TrashItemKind: String, Sendable, Equatable, Hashable {
    case applicationBundle
    case relatedFile
}

public struct TrashItem: Sendable, Equatable, Hashable {
    public var path: String
    public var kind: TrashItemKind

    public init(path: String, kind: TrashItemKind) {
        self.path = path
        self.kind = kind
    }
}

public struct TrashAuthorization: Sendable, Equatable {
    public var bundleIdentifiers: [String]
    public var permittedPaths: Set<String>
    public var currentApplicationPath: String?

    public init(
        bundleIdentifiers: [String],
        permittedPaths: Set<String>,
        currentApplicationPath: String?
    ) {
        self.bundleIdentifiers = bundleIdentifiers
        self.permittedPaths = permittedPaths
        self.currentApplicationPath = currentApplicationPath
    }
}

public enum RejectionReason: String, Sendable, Equatable, Hashable, Error {
    case notPermitted
    case outsideAllowedRoots
    case sensitiveLocation
    case unrelatedAppleFile
    case systemLocation
    case escapesRoot
    case notAnApplicationBundle
    case missingTarget
    case pathTooShallow
    case currentApplication
    case unexpectedApplicationLocation
}

public struct TrashFailure: Sendable, Equatable {
    public var path: String
    public var reason: RejectionReason?
    public var message: String
    public var needsAdministrator: Bool
    public var authorizationCanceled: Bool

    public init(
        path: String,
        reason: RejectionReason?,
        message: String,
        needsAdministrator: Bool = false,
        authorizationCanceled: Bool = false
    ) {
        self.path = path
        self.reason = reason
        self.message = message
        self.needsAdministrator = needsAdministrator
        self.authorizationCanceled = authorizationCanceled
    }
}

public struct TrashResult: Sendable, Equatable {
    public var trashed: [String]
    public var failed: [TrashFailure]
    public var abortedBeforeDeletion: Bool

    public init(trashed: [String], failed: [TrashFailure], abortedBeforeDeletion: Bool) {
        self.trashed = trashed
        self.failed = failed
        self.abortedBeforeDeletion = abortedBeforeDeletion
    }
}
