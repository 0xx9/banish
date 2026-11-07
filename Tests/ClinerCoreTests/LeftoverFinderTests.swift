import XCTest
@testable import ClinerCore

final class LeftoverFinderTests: XCTestCase {
    func testFindsStrongLeftoversAndSkipsLookalikes() throws {
        let fixture = try Fixture()
        defer { fixture.destroy() }

        try fixture.directory("home/Library/Application Support/Google/Chrome")
        try fixture.directory("home/Library/Application Support/Google/Earth")
        try fixture.directory("home/Library/Application Support/Other/Chrome")
        try fixture.file("home/Library/Preferences/com.google.Chrome.plist")
        try fixture.file("home/Library/Preferences/com.google.Chrome.helper.plist")
        try fixture.file("home/Library/Preferences/com.google.Chromium.plist")
        try fixture.file("home/Library/Preferences/com.google.Chrome2.plist")
        try fixture.file("home/Library/Preferences/ByHost/com.google.Chrome.ABCD.plist")
        try fixture.directory("home/Library/Containers/com.google.Chrome")
        try fixture.directory("home/Library/Containers/Chrome")
        try fixture.directory("home/Library/Caches/com.apple.Safari")
        try fixture.directory("home/Library/Group Containers/group.com.google.Chrome")
        try fixture.directory("home/Library/Saved Application State/com.google.Chrome.savedState")
        try fixture.directory("home/Library/HTTPStorages/com.google.Chrome")
        try fixture.directory("home/Library/Developer/Google Chrome")
        try fixture.directory("home/Library/Developer/Something/Google Chrome")
        try fixture.directory("home/Library/Mail/Google Chrome")
        try fixture.plist("home/Library/LaunchAgents/good.plist", ["Label": "com.google.Chrome"])
        try fixture.plist("home/Library/LaunchAgents/program.plist", [
            "Label": "com.other.agent",
            "ProgramArguments": ["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"]
        ])
        try fixture.plist("home/Library/LaunchAgents/lookalike.plist", [
            "Label": "com.other.agent",
            "ProgramArguments": ["/Applications/Google Chrome.app.backup/Contents/MacOS/Google Chrome"]
        ])
        try fixture.plist("home/Library/LaunchAgents/bad.plist", ["Label": "com.unrelated.agent"])
        let outside = fixture.root.appendingPathComponent("outside")
        try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            at: fixture.url("home/Library/Caches/escape"),
            withDestinationURL: outside
        )

        let scan = LeftoverFinder(scope: LeftoverSearchScope(userLibrary: fixture.url("home/Library").path))
            .find(for: chrome)

        assertContains(scan, "Application Support/Google/Chrome", reason: .companyProduct)
        assertContains(scan, "Preferences/com.google.Chrome.plist", reason: .bundleIdentifier)
        assertContains(scan, "Preferences/com.google.Chrome.helper.plist", reason: .bundleIdentifier)
        assertContains(scan, "Preferences/ByHost/com.google.Chrome.ABCD.plist", reason: .bundleIdentifier)
        assertContains(scan, "Containers/com.google.Chrome", reason: .bundleIdentifier)
        assertContains(scan, "Group Containers/group.com.google.Chrome", reason: .bundleIdentifier)
        assertContains(scan, "Saved Application State/com.google.Chrome.savedState", reason: .bundleIdentifier)
        assertContains(scan, "HTTPStorages/com.google.Chrome", reason: .bundleIdentifier)
        assertContains(scan, "Developer/Google Chrome", reason: .exactName)
        assertContains(scan, "LaunchAgents/good.plist", reason: .bundleIdentifier)
        assertContains(scan, "LaunchAgents/program.plist", reason: .launchAgentProgram)

        assertAbsent(scan, "Application Support/Google/Earth")
        assertAbsent(scan, "Application Support/Other/Chrome")
        assertAbsent(scan, "Preferences/com.google.Chromium.plist")
        assertAbsent(scan, "Preferences/com.google.Chrome2.plist")
        assertAbsent(scan, "Containers/Chrome")
        assertAbsent(scan, "Caches/com.apple.Safari")
        assertAbsent(scan, "Developer/Something/Google Chrome")
        assertAbsent(scan, "Mail/Google Chrome")
        assertAbsent(scan, "LaunchAgents/lookalike.plist")
        assertAbsent(scan, "LaunchAgents/bad.plist")
        assertAbsent(scan, "Caches/escape")
    }

    private var chrome: AppFingerprint {
        AppFingerprint(
            displayName: "Google Chrome",
            bundleIdentifier: "com.google.Chrome",
            executableName: "Google Chrome",
            matchNames: ["Google Chrome"],
            associatedBundleIdentifiers: [],
            bundlePath: "/Applications/Google Chrome.app"
        )
    }

    private func assertContains(_ scan: LeftoverScan, _ suffix: String, reason: MatchReason) {
        let match = scan.items.first { $0.path.hasSuffix(suffix) }
        XCTAssertNotNil(match, suffix)
        XCTAssertEqual(match?.reason, reason, suffix)
    }

    private func assertAbsent(_ scan: LeftoverScan, _ suffix: String) {
        XCTAssertFalse(scan.items.contains { $0.path.hasSuffix(suffix) }, suffix)
    }
}
