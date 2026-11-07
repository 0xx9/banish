import XCTest
@testable import ClinerCore

final class MatcherTests: XCTestCase {
    func testBundleIDPrefixDoesNotMatchLongerIdentifier() {
        XCTAssertFalse(Matcher.matchesBundleID(entryName: "com.foo.application.plist", bundleID: "com.foo.app"))
        XCTAssertFalse(Matcher.matchesBundleID(entryName: "com.foo.app2.plist", bundleID: "com.foo.app"))
        XCTAssertFalse(Matcher.matchesBundleID(entryName: "group.com.foo.application", bundleID: "com.foo.app"))
        XCTAssertFalse(Matcher.matchesBundleID(entryName: "com.google.Chromium.plist", bundleID: "com.google.Chrome"))
    }

    func testBundleIDMatchesExactPrefixGroupAndSavedState() {
        XCTAssertTrue(Matcher.matchesBundleID(entryName: "com.foo.app", bundleID: "com.foo.app"))
        XCTAssertTrue(Matcher.matchesBundleID(entryName: "com.foo.app.helper.plist", bundleID: "com.foo.app"))
        XCTAssertTrue(Matcher.matchesBundleID(entryName: "com.foo.app.ABCD.plist", bundleID: "com.foo.app"))
        XCTAssertTrue(Matcher.matchesBundleID(entryName: "group.com.foo.app", bundleID: "com.foo.app"))
        XCTAssertTrue(Matcher.matchesBundleID(entryName: "com.foo.app.savedState", bundleID: "com.foo.app"))
        XCTAssertTrue(Matcher.matchesBundleID(entryName: "com.foo.app.binarycookies", bundleID: "com.foo.app"))
    }

    func testExactNameRejectsGenericAndPartialNames() {
        let query = MatchQuery(
            bundleIdentifiers: ["com.nimbus.App"],
            matchNames: ["Nimbus", "Safari", "Client"],
            executableNames: ["Nimbus"],
            companies: ["nimbus"],
            products: ["App"]
        )
        XCTAssertEqual(Matcher.matchExactName("Nimbus", query: query), .exactName)
        XCTAssertNil(Matcher.matchExactName("NimbusHelper", query: query))
        XCTAssertNil(Matcher.matchExactName("Safari", query: query))
        XCTAssertNil(Matcher.matchExactName("Client", query: query))
        XCTAssertNil(Matcher.matchExactName("Pro", query: query))
    }

    func testCompanyProductRequiresParentCompany() {
        let query = MatchQuery.make(from: AppFingerprint(
            displayName: "Google Chrome",
            bundleIdentifier: "com.google.Chrome",
            executableName: "Google Chrome",
            matchNames: ["Google Chrome"],
            associatedBundleIdentifiers: [],
            bundlePath: "/Applications/Google Chrome.app"
        ))
        XCTAssertEqual(Matcher.matchCompanyProduct(child: "Chrome", parent: "Google", query: query), .companyProduct)
        XCTAssertNil(Matcher.matchCompanyProduct(child: "Earth", parent: "Google", query: query))
        XCTAssertNil(Matcher.matchCompanyProduct(child: "Chrome", parent: "Other", query: query))
        XCTAssertNil(Matcher.matchExactName("Chrome", query: query))
        XCTAssertEqual(Matcher.matchExactName("Google Chrome", query: query), .exactName)
    }

    func testGenericProductTokenIsNotUsed() {
        let products = Matcher.products(in: ["com.spotify.client", "org.videolan.vlc"])
        XCTAssertFalse(products.contains { $0.lowercased() == "client" })
        XCTAssertTrue(products.contains { $0.lowercased() == "vlc" })
    }

    func testPathPrefixDoesNotTreatUsrAsUsers() {
        XCTAssertFalse(PathSafety.hasPrefix("/Users/me/Library", "/usr"))
        XCTAssertTrue(PathSafety.hasPrefix("/usr/bin/swift", "/usr"))
        XCTAssertTrue(PathSafety.isStrictlyInside("/Applications/Orbit.app", "/Applications"))
        XCTAssertFalse(PathSafety.isStrictlyInside("/Applications", "/Applications"))
        XCTAssertTrue(PathSafety.containsTraversal("/tmp/../etc/passwd"))
    }
}
