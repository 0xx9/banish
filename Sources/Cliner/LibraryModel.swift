import AppKit
import ClinerCore
import Foundation
import Observation

enum AppSort: String, CaseIterable, Identifiable, Hashable {
    case name
    case size

    var id: String { rawValue }
}

enum LibraryNotice: Equatable, Hashable {
    case success(count: Int)
    case quitFailed
    case partial(ok: Int, failed: Int, detail: String)
    case rejected(RejectionReason)
    case failed(String)
    case nothingSelected
    case authorizationCanceled(moved: Int)
}

struct LeftoverRow: Identifiable, Equatable {
    var match: LeftoverMatch
    var isSelected: Bool

    var id: String { match.path }
}

@MainActor
@Observable
final class LibraryModel {
    var applications: [InstalledApp] = []
    var query = ""
    var sort: AppSort = .name
    var selectedID: String?
    var leftoverRows: [LeftoverRow] = []
    var removeBundle = true
    var isScanning = false
    var isLoadingLeftovers = false
    var isTrashing = false
    var accessDenied: [String] = []
    var permissionBannerDismissed = false
    var unreadableApplicationDirectories: [String] = []
    var notice: LibraryNotice?
    var askToConfirm = false
    var didStart = false

    private var runningBundleIDs: Set<String> = []
    private var scanGeneration = 0
    private var leftoverGeneration = 0

    var selectedApp: InstalledApp? {
        guard let selectedID else { return nil }
        return applications.first { $0.id == selectedID }
    }

    var canTrash: Bool {
        guard let app = selectedApp, !app.isProtected, !isTrashing, !isLoadingLeftovers else { return false }
        return !itemsToTrash.isEmpty
    }

    var itemsToTrash: [TrashItem] {
        guard let app = selectedApp, !app.isProtected else { return [] }
        var items: [TrashItem] = []
        if removeBundle {
            items.append(TrashItem(path: app.path, kind: .applicationBundle))
        }
        for row in leftoverRows where row.isSelected {
            items.append(TrashItem(path: row.match.path, kind: .relatedFile))
        }
        return items
    }

    func isRunning(_ app: InstalledApp) -> Bool {
        guard !app.bundleIdentifier.isEmpty else { return false }
        return runningBundleIDs.contains(app.bundleIdentifier)
    }

    func selectedBytes() -> Int64? {
        guard selectedApp?.isProtected != true else { return 0 }
        var total: Int64 = 0
        if removeBundle, let app = selectedApp {
            guard let size = app.sizeBytes else { return nil }
            total += size
        }
        for row in leftoverRows where row.isSelected {
            guard let size = row.match.sizeBytes else { return nil }
            total += size
        }
        return total
    }

    func relatedBytes() -> Int64? {
        if isLoadingLeftovers && leftoverRows.isEmpty { return nil }
        var total: Int64 = 0
        for row in leftoverRows {
            guard let size = row.match.sizeBytes else { return nil }
            total += size
        }
        return total
    }

    func requestTrashConfirmation() {
        guard canTrash else {
            if itemsToTrash.isEmpty, selectedApp?.isProtected != true {
                notice = .nothingSelected
            }
            return
        }
        askToConfirm = true
    }

    func refresh() async {
        scanGeneration += 1
        let generation = scanGeneration
        leftoverGeneration += 1
        isScanning = true
        permissionBannerDismissed = false
        let currentPath = Bundle.main.bundleURL.path
        let locations = ScanLocations.systemDefault(currentApplicationPath: currentPath)
        let result = await Task.detached {
            AppScanner().scan(locations)
        }.value
        guard generation == scanGeneration else { return }

        let previous = selectedID
        applications = result.apps
        unreadableApplicationDirectories = result.unreadableDirectories
        isScanning = false
        refreshRunningState()
        if selectedID == nil || !applications.contains(where: { $0.id == selectedID }) {
            selectedID = applications.first { !$0.isProtected }?.id
        }
        let paths = applications.map(\.path)
        if selectedID == previous {
            await loadLeftovers()
        }
        await sizeApplications(paths, generation: generation)
    }

    func loadLeftovers() async {
        leftoverGeneration += 1
        let generation = leftoverGeneration
        guard let id = selectedID, let app = applications.first(where: { $0.id == id }) else {
            leftoverRows = []
            accessDenied = []
            removeBundle = true
            isLoadingLeftovers = false
            return
        }
        if app.isProtected {
            leftoverRows = []
            accessDenied = []
            removeBundle = false
            isLoadingLeftovers = false
            return
        }

        isLoadingLeftovers = true
        leftoverRows = []
        removeBundle = true
        let fingerprint = app.fingerprint
        let scan = await Task.detached {
            LeftoverFinder(scope: .systemDefault()).find(for: fingerprint)
        }.value
        guard generation == leftoverGeneration, selectedID == id else { return }
        accessDenied = scan.accessDenied
        leftoverRows = scan.items.map { LeftoverRow(match: $0, isSelected: $0.reason.isStrong) }
        isLoadingLeftovers = false
        await sizeLeftovers(appID: id, generation: generation)
    }

    func watchRunningApps() async {
        while !Task.isCancelled {
            refreshRunningState()
            try? await Task.sleep(for: .seconds(3))
        }
    }

    func setLeftoverSelected(_ id: String, _ selected: Bool) {
        guard let index = leftoverRows.firstIndex(where: { $0.id == id }) else { return }
        leftoverRows[index].isSelected = selected
    }

    func setStrongSelection(_ selected: Bool) {
        for index in leftoverRows.indices where leftoverRows[index].match.reason.isStrong {
            leftoverRows[index].isSelected = selected
        }
    }

    func setWeakSelection(_ selected: Bool) {
        for index in leftoverRows.indices where !leftoverRows[index].match.reason.isStrong {
            leftoverRows[index].isSelected = selected
        }
    }

    func performTrash(adminPrompt: String) async -> Bool {
        guard let app = selectedApp, !app.isProtected else {
            notice = .rejected(.systemLocation)
            return false
        }
        if app.bundleIdentifier == "com.cliner.app" {
            notice = .rejected(.currentApplication)
            return false
        }
        let items = itemsToTrash
        guard !items.isEmpty else {
            notice = .nothingSelected
            return false
        }

        isTrashing = true
        defer { isTrashing = false }

        if needsQuit(app) {
            let quit = await quit(app)
            if !quit {
                notice = .quitFailed
                return false
            }
        }

        let permitted = Set(leftoverRows.map(\.match.path) + [app.path])
        let authorization = TrashAuthorization(
            bundleIdentifiers: app.fingerprint.bundleIdentifiers,
            permittedPaths: permitted,
            currentApplicationPath: Bundle.main.bundleURL.path
        )
        var result = await Task.detached {
            Uninstaller().trash(items, authorization: authorization)
        }.value
        result = elevateIfNeeded(
            result,
            items: items,
            authorization: authorization,
            prompt: adminPrompt
        )

        if result.abortedBeforeDeletion {
            if let reason = result.failed.first?.reason {
                notice = .rejected(reason)
            } else {
                notice = .failed(result.failed.first?.message ?? "")
            }
            return false
        }

        let removedApp = result.trashed.contains { PathSafety.sameFile($0, app.path) }
        if removedApp {
            applications.removeAll { $0.id == app.id }
            selectedID = applications.first { !$0.isProtected }?.id
            leftoverRows = []
        } else if selectedID == app.id {
            await loadLeftovers()
        }

        if result.failed.contains(where: \.authorizationCanceled) {
            notice = .authorizationCanceled(moved: result.trashed.count)
            return result.trashed.isEmpty ? false : true
        }

        if result.failed.isEmpty {
            notice = .success(count: result.trashed.count)
            return true
        }
        if result.trashed.isEmpty {
            notice = .failed(result.failed.first?.message ?? "")
            return false
        }
        notice = .partial(
            ok: result.trashed.count,
            failed: result.failed.count,
            detail: result.failed.first?.message ?? ""
        )
        return true
    }

    private func elevateIfNeeded(
        _ result: TrashResult,
        items: [TrashItem],
        authorization: TrashAuthorization,
        prompt: String
    ) -> TrashResult {
        let denied = result.failed.filter(\.needsAdministrator)
        guard !result.abortedBeforeDeletion, !denied.isEmpty else { return result }
        let elevated = AdministratorTrash.move(
            paths: denied.map(\.path),
            items: items,
            authorization: authorization,
            prompt: prompt
        )
        let deniedPaths = Set(denied.map { PathSafety.lexical($0.path).lowercased() })
        let keptFailures = result.failed.filter {
            !deniedPaths.contains(PathSafety.lexical($0.path).lowercased())
        }
        return TrashResult(
            trashed: result.trashed + elevated.trashed,
            failed: keptFailures + elevated.failed,
            abortedBeforeDeletion: result.trashed.isEmpty && elevated.trashed.isEmpty && elevated.abortedBeforeDeletion
        )
    }

    private func needsQuit(_ app: InstalledApp) -> Bool {
        guard isRunning(app) else { return false }
        return removeBundle || leftoverRows.contains(where: \.isSelected)
    }

    private func quit(_ app: InstalledApp) async -> Bool {
        let bundleID = app.bundleIdentifier
        guard !bundleID.isEmpty else { return true }
        let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        if running.isEmpty { return true }
        running.forEach { $0.terminate() }
        for _ in 0..<25 {
            try? await Task.sleep(for: .milliseconds(200))
            if NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty {
                refreshRunningState()
                return true
            }
        }
        refreshRunningState()
        return false
    }

    private func refreshRunningState() {
        runningBundleIDs = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
    }

    private func sizeApplications(_ paths: [String], generation: Int) async {
        for await (path, size) in BackgroundMeter.sizes(for: paths) {
            guard generation == scanGeneration else { return }
            if let index = applications.firstIndex(where: { $0.path == path }) {
                applications[index].sizeBytes = size ?? 0
            }
        }
        guard generation == scanGeneration else { return }
        for index in applications.indices where applications[index].sizeBytes == nil {
            applications[index].sizeBytes = 0
        }
    }

    private func sizeLeftovers(appID: String, generation: Int) async {
        let paths = leftoverRows.map(\.match.path)
        for await (path, size) in BackgroundMeter.sizes(for: paths) {
            guard generation == leftoverGeneration, selectedID == appID else { return }
            guard let index = leftoverRows.firstIndex(where: { $0.match.path == path }) else { continue }
            leftoverRows[index].match.sizeBytes = size ?? 0
        }
        guard generation == leftoverGeneration, selectedID == appID else { return }
        for index in leftoverRows.indices where leftoverRows[index].match.sizeBytes == nil {
            leftoverRows[index].match.sizeBytes = 0
        }
    }
}
