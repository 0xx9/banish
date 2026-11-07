import Foundation

public struct MatchQuery: Sendable, Equatable {
    public var bundleIdentifiers: [String]
    public var matchNames: [String]
    public var executableNames: [String]
    public var companies: [String]
    public var products: [String]

    public init(
        bundleIdentifiers: [String],
        matchNames: [String],
        executableNames: [String],
        companies: [String],
        products: [String]
    ) {
        self.bundleIdentifiers = bundleIdentifiers
        self.matchNames = matchNames
        self.executableNames = executableNames
        self.companies = companies
        self.products = products
    }

    public static func make(from fingerprint: AppFingerprint) -> MatchQuery {
        let identifiers = fingerprint.bundleIdentifiers
        var names = fingerprint.matchNames
        if !fingerprint.displayName.isEmpty {
            names.append(fingerprint.displayName)
        }
        if !fingerprint.executableName.isEmpty {
            names.append(fingerprint.executableName)
        }
        return MatchQuery(
            bundleIdentifiers: uniqueStrings(identifiers),
            matchNames: uniqueStrings(names),
            executableNames: fingerprint.executableName.isEmpty ? [] : [fingerprint.executableName],
            companies: Matcher.companies(in: identifiers),
            products: Matcher.products(in: identifiers)
        )
    }
}

public enum Matcher {
    public static func matchesBundleID(entryName: String, bundleID: String) -> Bool {
        let identifier = bundleID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard identifier.count >= 3, identifier.contains(".") else { return false }

        var stem = entryName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        for suffix in [".plist", ".savedstate", ".binarycookies"] where stem.hasSuffix(suffix) {
            stem.removeLast(suffix.count)
            break
        }
        if stem.hasPrefix("group.") {
            stem.removeFirst("group.".count)
        }
        if stem == identifier {
            return true
        }
        for separator in [".", "-", "_", " "] where stem.hasPrefix(identifier + separator) {
            return true
        }
        return false
    }

    public static func normalizeName(_ raw: String) -> String {
        let folded = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let scalars = folded.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }
        return String(String.UnicodeScalarView(scalars))
    }

    public static func isSignificantStandalone(_ normalized: String) -> Bool {
        normalized.count >= 3 && !standaloneBlocked.contains(normalized)
    }

    public static func matchExactName(_ entryName: String, query: MatchQuery) -> MatchReason? {
        let normalized = normalizeName(entryName)
        guard isSignificantStandalone(normalized) else { return nil }
        let candidates = query.matchNames + query.executableNames
        guard candidates.contains(where: { normalizeName($0) == normalized }) else { return nil }
        return .exactName
    }

    public static func matchCompanyProduct(child: String, parent: String, query: MatchQuery) -> MatchReason? {
        let parentName = normalizeName(parent)
        guard parentName.count >= 3, !genericCompany.contains(parentName) else { return nil }
        guard query.companies.contains(where: { normalizeName($0) == parentName }) else { return nil }

        let childName = normalizeName(child)
        guard childName.count >= 3 else { return nil }

        let named = (query.matchNames + query.executableNames).contains { normalizeName($0) == childName }
        if named && isSignificantStandalone(childName) {
            return .companyProduct
        }
        let productHit = query.products.contains {
            let product = normalizeName($0)
            return product == childName && !genericProduct.contains(product)
        }
        return productHit ? .companyProduct : nil
    }

    public static func companies(in bundleIDs: [String]) -> [String] {
        bundleIDs.compactMap { identifier in
            let parts = identifier.split(separator: ".").map(String.init)
            guard parts.count >= 3 else { return nil }
            return parts[1]
        }
    }

    public static func products(in bundleIDs: [String]) -> [String] {
        bundleIDs.compactMap { identifier in
            let parts = identifier.split(separator: ".").map(String.init)
            guard parts.count >= 2, let last = parts.last else { return nil }
            let normalized = normalizeName(last)
            guard normalized.count >= 3, !genericProduct.contains(normalized) else { return nil }
            return last
        }
    }

    static let standaloneBlocked: Set<String> = [
        "app", "application", "applications", "helper", "updater", "update", "agent", "service",
        "plugin", "plugins", "extension", "extensions", "client", "desktop", "mac", "osx", "macos",
        "cocoa", "electron", "crashpad", "crashreporter", "launcher", "installer", "uninstaller",
        "library", "system", "preferences", "caches", "cache", "logs", "log", "cookies", "webkit",
        "developer", "shared", "common", "public", "private", "support", "data", "container",
        "containers", "framework", "frameworks", "resources", "contents", "users", "user", "group",
        "core", "main", "default", "config", "settings", "setting", "music", "photos", "safari",
        "finder", "mail", "notes", "messages", "maps", "preview", "calendar", "contacts",
        "reminders", "shortcuts", "news", "stocks", "podcasts", "facetime", "textedit", "tv",
        "home", "root", "bin", "tmp", "temp", "var", "usr", "lib", "pro", "dev", "tool", "tools",
        "node", "java", "python", "ruby", "git", "npm", "brew", "google", "adobe", "microsoft",
        "apple", "itunes", "icloud", "backup", "backups", "sync", "daemon", "daemons", "login",
        "logout", "menu", "bar", "status", "widget", "widgets", "admin"
    ]

    static let genericCompany: Set<String> = [
        "com", "org", "net", "io", "co", "app", "www", "desktop", "shared", "common", "me"
    ]

    static let genericProduct: Set<String> = [
        "client", "helper", "agent", "service", "app", "desktop", "electron", "plugin", "updater",
        "launcher", "main", "mac", "osx", "cocoa", "framework", "core", "common", "shared", "data",
        "support", "tool", "tools", "bin", "lib", "default", "config", "update", "installer",
        "crashpad", "node"
    ]
}

private func uniqueStrings(_ values: [String]) -> [String] {
    var seen = Set<String>()
    var result: [String] = []
    for value in values {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, seen.insert(trimmed.lowercased()).inserted else { continue }
        result.append(trimmed)
    }
    return result
}
