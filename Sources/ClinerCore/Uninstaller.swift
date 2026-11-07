import Foundation

public protocol ItemTrashing: Sendable {
    func moveToTrash(_ path: String) throws
}

public struct FileManagerTrashing: ItemTrashing {
    public init() {}

    public func moveToTrash(_ path: String) throws {
        let lexical = PathSafety.lexical(path)
        for root in ["/system", "/usr", "/bin", "/sbin", "/etc", "/private", "/var", "/dev", "/opt", "/cores", "/tmp"] {
            if PathSafety.hasPrefix(lexical, root) {
                throw CocoaError(.fileWriteNoPermission)
            }
        }
        try FileManager().trashItem(at: URL(fileURLWithPath: lexical), resultingItemURL: nil)
    }
}

public struct Uninstaller: Sendable {
    private let policy: DeletionPolicy
    private let trashing: any ItemTrashing

    public init(userHome: String? = nil, trashing: (any ItemTrashing)? = nil) {
        let home = userHome ?? FileManager.default.homeDirectoryForCurrentUser.path
        self.policy = DeletionPolicy(userHome: home)
        self.trashing = trashing ?? FileManagerTrashing()
    }

    public func trash(_ items: [TrashItem], authorization: TrashAuthorization) -> TrashResult {
        guard !items.isEmpty else {
            return TrashResult(trashed: [], failed: [], abortedBeforeDeletion: false)
        }

        for item in items {
            if let reason = policy.rejectionReason(for: item, authorization: authorization) {
                return aborted(item.path, reason: reason)
            }
        }

        let fileManager = FileManager()
        for item in items where item.kind == .applicationBundle && fileManager.fileExists(atPath: item.path) {
            var isDirectory = ObjCBool(false)
            fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory)
            if !isDirectory.boolValue || !item.path.lowercased().hasSuffix(".app") {
                return aborted(item.path, reason: .notAnApplicationBundle)
            }
        }

        var trashed: [String] = []
        var failed: [TrashFailure] = []
        for item in items {
            if !fileManager.fileExists(atPath: item.path) {
                failed.append(TrashFailure(path: item.path, reason: .missingTarget, message: "missing"))
                continue
            }
            do {
                try trashing.moveToTrash(item.path)
                trashed.append(item.path)
            } catch {
                failed.append(
                    TrashFailure(
                        path: item.path,
                        reason: nil,
                        message: error.localizedDescription,
                        needsAdministrator: TrashPermissions.isDenied(error)
                    )
                )
            }
        }
        return TrashResult(trashed: trashed, failed: failed, abortedBeforeDeletion: false)
    }

    private func aborted(_ path: String, reason: RejectionReason) -> TrashResult {
        TrashResult(
            trashed: [],
            failed: [TrashFailure(path: path, reason: reason, message: reason.rawValue)],
            abortedBeforeDeletion: true
        )
    }
}
