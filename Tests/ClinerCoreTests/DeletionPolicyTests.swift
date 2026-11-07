import XCTest
@testable import ClinerCore

final class DeletionPolicyTests: XCTestCase {
    private let home = "/Users/me"
    private var policy: DeletionPolicy!

    override func setUp() {
        super.setUp()
        policy = DeletionPolicy(userHome: home)
    }

    func testAllowsCacheAndApplicationBundle() {
        let cache = "/Users/me/Library/Caches/com.nimbus.App"
        XCTAssertNil(policy.rejectionReason(for: related(cache), authorization: auth(cache)))

        let app = "/Applications/Nimbus.app"
        XCTAssertNil(policy.rejectionReason(for: bundle(app), authorization: auth(app)))
        XCTAssertNil(
            policy.rejectionReason(
                for: bundle("/Applications/Utilities/Nimbus.app"),
                authorization: auth("/Applications/Utilities/Nimbus.app")
            )
        )
    }

    func testRejectsUnsafeLocationsEvenWhenPermitted() {
        let cases: [(TrashItem, RejectionReason)] = [
            (related("/Users/me/Library/Caches"), .pathTooShallow),
            (related("/Users/me/Library/Mail/Orbit"), .sensitiveLocation),
            (related("/Users/me/Documents/Orbit"), .sensitiveLocation),
            (related("/Users/me/Library/Caches/com.apple.Safari"), .unrelatedAppleFile),
            (bundle("/System/Applications/Calculator.app"), .systemLocation),
            (bundle("/usr/local/Nimbus.app"), .systemLocation),
            (bundle("/Applications/A/B/Nimbus.app"), .unexpectedApplicationLocation),
            (related("/Applications/Nimbus.app"), .outsideAllowedRoots),
            (related("/Users/me/Library/Caches/com.nimbus.App"), .notPermitted)
        ]
        for (item, reason) in cases {
            let authorization = auth(item.path, identifiers: ["com.nimbus.App"])
            let permitted = item.path == "/Users/me/Library/Caches/com.nimbus.App"
                ? TrashAuthorization(bundleIdentifiers: ["com.nimbus.App"], permittedPaths: [], currentApplicationPath: nil)
                : authorization
            XCTAssertEqual(
                policy.rejectionReason(for: item, authorization: permitted),
                reason,
                item.path
            )
        }
    }

    func testAppleAppCanRemoveItsOwnFilesButNotSafari() {
        let xcode = "/Users/me/Library/Caches/com.apple.dt.Xcode"
        let safari = "/Users/me/Library/Caches/com.apple.Safari"
        let authorization = TrashAuthorization(
            bundleIdentifiers: ["com.apple.dt.Xcode"],
            permittedPaths: [xcode, safari],
            currentApplicationPath: nil
        )
        XCTAssertNil(policy.rejectionReason(for: related(xcode), authorization: authorization))
        XCTAssertEqual(
            policy.rejectionReason(for: related(safari), authorization: authorization),
            .unrelatedAppleFile
        )
    }

    func testRejectsCurrentApplicationAndTraversal() {
        let app = "/Applications/Cliner.app"
        let authorization = TrashAuthorization(
            bundleIdentifiers: ["com.cliner.app"],
            permittedPaths: [app, "/Users/me/../../etc/passwd"],
            currentApplicationPath: app
        )
        XCTAssertEqual(policy.rejectionReason(for: bundle(app), authorization: authorization), .currentApplication)
        XCTAssertEqual(
            policy.rejectionReason(for: related("/Users/me/../../etc/passwd"), authorization: authorization),
            .escapesRoot
        )
    }

    func testRejectsSymlink() throws {
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cliner-link-\(UUID().uuidString)")
        let home = root.appendingPathComponent("home")
        let cache = home.appendingPathComponent("Library/Caches")
        try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let link = cache.appendingPathComponent("com.nimbus.App")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: root.appendingPathComponent("outside"))

        let local = DeletionPolicy(userHome: home.path)
        let authorization = TrashAuthorization(
            bundleIdentifiers: ["com.nimbus.App"],
            permittedPaths: [link.path],
            currentApplicationPath: nil
        )
        XCTAssertEqual(local.rejectionReason(for: related(link.path), authorization: authorization), .escapesRoot)
    }

    private func related(_ path: String) -> TrashItem {
        TrashItem(path: path, kind: .relatedFile)
    }

    private func bundle(_ path: String) -> TrashItem {
        TrashItem(path: path, kind: .applicationBundle)
    }

    private func auth(_ path: String, identifiers: [String] = ["com.nimbus.App"]) -> TrashAuthorization {
        TrashAuthorization(bundleIdentifiers: identifiers, permittedPaths: [path], currentApplicationPath: nil)
    }
}
