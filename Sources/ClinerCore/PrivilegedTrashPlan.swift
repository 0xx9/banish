import Foundation

public struct PrivilegedMove: Sendable, Equatable {
    public var source: String
    public var destination: String

    public init(source: String, destination: String) {
        self.source = source
        self.destination = destination
    }
}

public struct PrivilegedTrashPlan: Sendable, Equatable {
    public var script: String
    public var moves: [PrivilegedMove]

    public init(script: String, moves: [PrivilegedMove]) {
        self.script = script
        self.moves = moves
    }
}

public enum TrashPermissions {
    public static func isDenied(_ error: Error) -> Bool {
        let nsError = error as NSError
        if isDenied(nsError) {
            return true
        }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            return isDenied(underlying)
        }
        return false
    }

    private static func isDenied(_ error: NSError) -> Bool {
        if error.domain == NSCocoaErrorDomain {
            let denied: Set<Int> = [
                CocoaError.fileWriteNoPermission.rawValue,
                CocoaError.fileReadNoPermission.rawValue
            ]
            if denied.contains(error.code) {
                return true
            }
        }
        if error.domain == NSPOSIXErrorDomain && (error.code == 1 || error.code == 13) {
            return true
        }
        return error.localizedDescription.lowercased().contains("permission")
    }
}

public enum PrivilegedTrashPlanner {
    /// Builds one administrator AppleScript that moves already-authorized items into the Trash.
    /// The script only uses `mv` and `chown`. A policy failure returns before a script exists.
    public static func plan(
        paths: [String],
        trashDirectory: String,
        userHome: String,
        uid: UInt32,
        gid: UInt32,
        prompt: String,
        authorization: TrashAuthorization,
        kinds: [String: TrashItemKind]
    ) -> Result<PrivilegedTrashPlan, RejectionReason> {
        let policy = DeletionPolicy(userHome: userHome)
        var reserved = Set<String>()
        var moves: [PrivilegedMove] = []

        for path in paths {
            if path.contains("\n") || path.contains("\r") {
                return .failure(.escapesRoot)
            }
            let kind = kinds[path] ?? (path.lowercased().hasSuffix(".app") ? .applicationBundle : .relatedFile)
            if let reason = policy.rejectionReason(for: TrashItem(path: path, kind: kind), authorization: authorization) {
                return .failure(reason)
            }
            let source = PathSafety.lexical(path)
            let name = URL(fileURLWithPath: source).lastPathComponent
            guard let destination = uniqueDestination(name: name, trashDirectory: trashDirectory, reserved: &reserved) else {
                return .failure(.outsideAllowedRoots)
            }
            moves.append(PrivilegedMove(source: source, destination: destination))
        }

        return .success(
            PrivilegedTrashPlan(
                script: appleScript(moves: moves, uid: uid, gid: gid, prompt: prompt),
                moves: moves
            )
        )
    }

    static func appleScript(moves: [PrivilegedMove], uid: UInt32, gid: UInt32, prompt: String) -> String {
        let commands = moves.map { move in
            let source = shellQuote(move.source)
            let destination = shellQuote(move.destination)
            return "mv \(source) \(destination) && { chown -R \(uid):\(gid) \(destination) || true; }"
        }
        let shell = commands.joined(separator: " && ")
        return "do shell script \(appleScriptLiteral(shell)) with prompt \(appleScriptLiteral(prompt)) with administrator privileges"
    }

    static func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    static func appleScriptLiteral(_ value: String) -> String {
        var escaped = ""
        for character in value {
            switch character {
            case "\\":
                escaped += "\\\\"
            case "\"":
                escaped += "\\\""
            default:
                escaped.append(character)
            }
        }
        return "\"\(escaped)\""
    }

    private static func uniqueDestination(name: String, trashDirectory: String, reserved: inout Set<String>) -> String? {
        let trash = PathSafety.lexical(trashDirectory)
        var index = 1
        var candidate = trash + "/" + name
        let fileManager = FileManager()
        while fileManager.fileExists(atPath: candidate) || reserved.contains(candidate.lowercased()) {
            index += 1
            guard index < 1000 else { return nil }
            candidate = trash + "/" + numberedName(name, index: index)
        }
        guard PathSafety.isStrictlyInside(candidate, trash) else { return nil }
        reserved.insert(candidate.lowercased())
        return candidate
    }

    private static func numberedName(_ fileName: String, index: Int) -> String {
        let url = URL(fileURLWithPath: fileName)
        let ext = url.pathExtension
        let base = url.deletingPathExtension().lastPathComponent
        if ext.isEmpty {
            return "\(base) \(index)"
        }
        return "\(base) \(index).\(ext)"
    }
}
