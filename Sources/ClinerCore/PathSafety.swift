import Foundation

public enum PathSafety {
    public static func lexical(_ path: String) -> String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }

    public static func isAbsolute(_ path: String) -> Bool {
        path.hasPrefix("/")
    }

    public static func containsTraversal(_ path: String) -> Bool {
        if path.contains("\0") {
            return true
        }
        return path.split(separator: "/").contains("..")
    }

    /// Prefix match that does not treat `/usr` as a prefix of `/Users`.
    public static func hasPrefix(_ path: String, _ root: String) -> Bool {
        let path = lexical(path).lowercased()
        let root = lexical(root).lowercased()
        if path == root {
            return true
        }
        let prefix = root.hasSuffix("/") ? root : root + "/"
        return path.hasPrefix(prefix)
    }

    public static func isStrictlyInside(_ path: String, _ root: String) -> Bool {
        let path = lexical(path).lowercased()
        let root = lexical(root).lowercased()
        guard path.count > root.count else { return false }
        let prefix = root.hasSuffix("/") ? root : root + "/"
        return path.hasPrefix(prefix)
    }

    public static func sameFile(_ lhs: String, _ rhs: String) -> Bool {
        if lexical(lhs).caseInsensitiveCompare(lexical(rhs)) == .orderedSame {
            return true
        }
        let left = URL(fileURLWithPath: lexical(lhs)).resolvingSymlinksInPath().path
        let right = URL(fileURLWithPath: lexical(rhs)).resolvingSymlinksInPath().path
        return left.caseInsensitiveCompare(right) == .orderedSame
    }
}
