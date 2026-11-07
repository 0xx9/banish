import XCTest
@testable import ClinerCore

/// These tests use a recording double. They must not call the real Trash.
final class UninstallerTests: XCTestCase {
    func testAbortsBeforeTrashingWhenAnyPathIsRejected() throws {
        let fixture = try Fixture()
        defer { fixture.destroy() }
        let cache = fixture.url("home/Library/Caches/com.nimbus.App")
        try fixture.directory("home/Library/Caches/com.nimbus.App")
        let mail = fixture.url("home/Library/Mail/secret")
        try fixture.directory("home/Library/Mail/secret")
        let recording = RecordingTrashing()
        let uninstaller = Uninstaller(userHome: fixture.url("home").path, trashing: recording)

        let result = uninstaller.trash(
            [
                TrashItem(path: cache.path, kind: .relatedFile),
                TrashItem(path: mail.path, kind: .relatedFile)
            ],
            authorization: TrashAuthorization(
                bundleIdentifiers: ["com.nimbus.App"],
                permittedPaths: [cache.path, mail.path],
                currentApplicationPath: nil
            )
        )

        XCTAssertTrue(result.abortedBeforeDeletion)
        XCTAssertTrue(result.trashed.isEmpty)
        XCTAssertEqual(result.failed.first?.reason, .sensitiveLocation)
        XCTAssertTrue(recording.paths.isEmpty)
        XCTAssertTrue(FileManager.default.fileExists(atPath: cache.path))
    }

    func testTrashesOnlyTheAuthorizedTempPath() throws {
        let fixture = try Fixture()
        defer { fixture.destroy() }
        let cache = fixture.url("home/Library/Caches/com.nimbus.App")
        let app = fixture.url("home/Applications/Nimbus.app")
        try fixture.directory("home/Library/Caches/com.nimbus.App")
        try fixture.directory("home/Applications/Nimbus.app/Contents")
        let recording = RecordingTrashing()
        let uninstaller = Uninstaller(userHome: fixture.url("home").path, trashing: recording)

        let result = uninstaller.trash(
            [
                TrashItem(path: cache.path, kind: .relatedFile),
                TrashItem(path: app.path, kind: .applicationBundle)
            ],
            authorization: TrashAuthorization(
                bundleIdentifiers: ["com.nimbus.App"],
                permittedPaths: [cache.path, app.path],
                currentApplicationPath: nil
            )
        )

        XCTAssertFalse(result.abortedBeforeDeletion)
        XCTAssertEqual(Set(result.trashed), Set([cache.path, app.path]))
        XCTAssertTrue(result.failed.isEmpty)
        XCTAssertEqual(Set(recording.paths), Set([cache.path, app.path]))
    }

    func testDoesNotCallTrashForSystemPathEvenIfPermitted() {
        let recording = RecordingTrashing()
        let uninstaller = Uninstaller(userHome: "/Users/me", trashing: recording)
        let systemApp = "/System/Applications/Calculator.app"
        let result = uninstaller.trash(
            [TrashItem(path: systemApp, kind: .applicationBundle)],
            authorization: TrashAuthorization(
                bundleIdentifiers: ["com.apple.calculator"],
                permittedPaths: [systemApp],
                currentApplicationPath: nil
            )
        )
        XCTAssertTrue(result.abortedBeforeDeletion)
        XCTAssertEqual(result.failed.first?.reason, .systemLocation)
        XCTAssertTrue(recording.paths.isEmpty)
    }
}

final class RecordingTrashing: ItemTrashing, @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [String] = []

    func moveToTrash(_ path: String) throws {
        lock.lock()
        recorded.append(path)
        lock.unlock()
    }

    var paths: [String] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }
}

final class DirectorySizerTests: XCTestCase {
    func testMeasuresARealFile() throws {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cliner-size-\(UUID().uuidString)")
        try Data(repeating: 7, count: 5000).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let size = try XCTUnwrap(DirectorySizer().allocatedSize(at: url.path))
        XCTAssertGreaterThanOrEqual(size, 4096)
    }
}

final class ByteTextTests: XCTestCase {
    func testFormatsBytes() {
        XCTAssertFalse(ByteText.format(0, locale: Locale(identifier: "en")).isEmpty)
        let megabyte = ByteText.format(1_048_576, locale: Locale(identifier: "en"))
        XCTAssertTrue(megabyte.contains("1"))
    }
}
