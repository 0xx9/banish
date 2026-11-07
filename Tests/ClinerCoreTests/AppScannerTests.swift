import XCTest
@testable import ClinerCore

final class AppScannerTests: XCTestCase {
    func testScansValidAppsAndSkipsNestedOrBrokenBundles() throws {
        let fixture = try Fixture()
        defer { fixture.destroy() }
        let applications = fixture.url("Applications")
        try fixture.plistApp("Applications/Orbit.app", [
            "CFBundleIdentifier": "com.orbit.App",
            "CFBundleName": "Orbit",
            "CFBundleDisplayName": "Orbit",
            "CFBundleExecutable": "Orbit",
            "CFBundleShortVersionString": "2.0"
        ])
        try fixture.plistApp("Applications/Orbit.app/Contents/PlugIns/Helper.appex", [
            "CFBundleIdentifier": "com.orbit.Helper",
            "CFBundleName": "Helper",
            "CFBundleExecutable": "Helper"
        ])
        try fixture.plistApp("Applications/Orbit.app/Contents/PlugIns/AppleShare.appex", [
            "CFBundleIdentifier": "com.apple.share.Service",
            "CFBundleName": "Share",
            "CFBundleExecutable": "Share"
        ])
        try fixture.directory("Applications/Broken.app/Contents")
        try fixture.plistApp("Applications/Utilities/Widget.app", [
            "CFBundleIdentifier": "com.widgets.Widget",
            "CFBundleName": "Widget",
            "CFBundleExecutable": "Widget",
            "CFBundleShortVersionString": "1"
        ])
        try fixture.plistApp("Applications/Too/Deep/Buried.app", [
            "CFBundleIdentifier": "com.buried.App",
            "CFBundleName": "Buried",
            "CFBundleExecutable": "Buried"
        ])
        try fixture.plistApp("Applications/Finder.app", [
            "CFBundleIdentifier": "com.apple.finder",
            "CFBundleName": "Finder",
            "CFBundleExecutable": "Finder"
        ])
        try fixture.plistApp("Applications/Keynote.app", [
            "CFBundleIdentifier": "com.apple.iWork.Keynote",
            "CFBundleName": "Keynote",
            "CFBundleExecutable": "Keynote"
        ])
        let system = fixture.url("System/Applications")
        try fixture.plistApp("System/Applications/Calc.app", [
            "CFBundleIdentifier": "com.example.Calc",
            "CFBundleName": "Calc",
            "CFBundleExecutable": "Calc"
        ])
        let current = applications.appendingPathComponent("Self.app")
        try fixture.plistApp("Applications/Self.app", [
            "CFBundleIdentifier": "com.example.Self",
            "CFBundleName": "Self",
            "CFBundleExecutable": "Self"
        ])
        let link = applications.appendingPathComponent("Linked.app")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: applications.appendingPathComponent("Orbit.app"))

        let result = AppScanner().scan(ScanLocations(
            applicationDirectories: [applications.path, system.path],
            maximumDepth: 2,
            currentApplicationPath: current.path,
            protectedPathPrefixes: [fixture.url("System").path]
        ))

        let orbit = try XCTUnwrap(result.apps.first { $0.name == "Orbit" })
        XCTAssertEqual(orbit.bundleIdentifier, "com.orbit.App")
        XCTAssertEqual(orbit.version, "2.0")
        XCTAssertNil(orbit.protectionReason)
        XCTAssertEqual(orbit.associatedBundleIdentifiers, ["com.orbit.Helper"])
        XCTAssertFalse(orbit.associatedBundleIdentifiers.contains("com.apple.share.Service"))

        XCTAssertNotNil(result.apps.first { $0.name == "Widget" })
        XCTAssertNil(result.apps.first { $0.bundleIdentifier == "com.buried.App" })
        XCTAssertNil(result.apps.first { $0.name == "Broken" })
        XCTAssertNil(result.apps.first { $0.name == "Linked" })
        XCTAssertEqual(result.apps.first { $0.name == "Finder" }?.protectionReason, .criticalAppleApp)
        XCTAssertNil(result.apps.first { $0.name == "Keynote" }?.protectionReason)
        XCTAssertEqual(result.apps.first { $0.name == "Calc" }?.protectionReason, .systemLocation)
        XCTAssertEqual(result.apps.first { $0.name == "Self" }?.protectionReason, .currentApplication)
    }
}
