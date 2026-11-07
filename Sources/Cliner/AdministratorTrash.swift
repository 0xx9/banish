import ClinerCore
import Foundation

enum AdministratorTrash {
    @MainActor
    static func move(
        paths: [String],
        items: [TrashItem],
        authorization: TrashAuthorization,
        prompt: String
    ) -> TrashResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let trash = home + "/.Trash"
        try? FileManager.default.createDirectory(atPath: trash, withIntermediateDirectories: true)
        var kinds: [String: TrashItemKind] = [:]
        for item in items {
            kinds[item.path] = item.kind
        }
        switch PrivilegedTrashPlanner.plan(
            paths: paths,
            trashDirectory: trash,
            userHome: home,
            uid: getuid(),
            gid: getgid(),
            prompt: prompt,
            authorization: authorization,
            kinds: kinds
        ) {
        case .failure(let reason):
            return TrashResult(
                trashed: [],
                failed: paths.map { TrashFailure(path: $0, reason: reason, message: reason.rawValue) },
                abortedBeforeDeletion: true
            )
        case .success(let plan):
            if plan.moves.isEmpty {
                return TrashResult(trashed: [], failed: [], abortedBeforeDeletion: false)
            }
            let outcome = runAppleScript(plan.script)
            let fileManager = FileManager()
            let moved = plan.moves.filter { !fileManager.fileExists(atPath: $0.source) }
            let stuck = plan.moves.filter { fileManager.fileExists(atPath: $0.source) }
            return TrashResult(
                trashed: moved.map(\.source),
                failed: stuck.map {
                    TrashFailure(
                        path: $0.source,
                        reason: nil,
                        message: outcome?.message ?? "",
                        authorizationCanceled: outcome?.canceled == true
                    )
                },
                abortedBeforeDeletion: false
            )
        }
    }

    private struct ScriptOutcome {
        var message: String
        var canceled: Bool
    }

    @MainActor
    private static func runAppleScript(_ source: String) -> ScriptOutcome? {
        var errorInfo: NSDictionary?
        let script = NSAppleScript(source: source)
        _ = script?.executeAndReturnError(&errorInfo)
        guard let errorInfo else { return nil }
        let number = (errorInfo["NSAppleScriptErrorNumber"] as? NSNumber)?.intValue ?? 0
        let message = errorInfo["NSAppleScriptErrorMessage"] as? String ?? ""
        return ScriptOutcome(message: message, canceled: number == -128)
    }
}
