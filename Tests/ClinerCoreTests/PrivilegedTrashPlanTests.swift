import XCTest
@testable import ClinerCore

final class PrivilegedTrashPlanTests: XCTestCase {
    func testBuildsOnePasswordPromptForAnApplicationsBundle() throws {
        let app = "/Applications/Multilogin.app"
        let plan = try XCTUnwrap(plan(paths: [app], kinds: [app: .applicationBundle]).get())
        XCTAssertEqual(plan.moves.map(\.source), [app])
        XCTAssertTrue(plan.moves[0].destination.hasSuffix("/.Trash/Multilogin.app"))
        XCTAssertTrue(plan.script.contains("with administrator privileges"))
        XCTAssertTrue(plan.script.contains("with prompt"))
        XCTAssertTrue(plan.script.contains("mv "))
        XCTAssertTrue(plan.script.contains("chown -R 501:20"))
        XCTAssertFalse(plan.script.contains("rm "))
    }

    func testQuotesApostrophesSoThePathCannotBreakTheCommand() throws {
        let app = "/Applications/It's Mine.app"
        let plan = try XCTUnwrap(plan(paths: [app], kinds: [app: .applicationBundle]).get())
        XCTAssertTrue(plan.script.contains("It'\\\\''s Mine.app"))
        XCTAssertFalse(plan.script.contains("rm "))
    }

    func testRefusesSystemPathsAndNewlinesBeforeBuildingAScript() {
        let system = "/System/Applications/Calculator.app"
        let systemResult = plan(paths: [system], kinds: [system: .applicationBundle])
        guard case .failure(let systemReason) = systemResult else {
            return XCTFail("expected a rejection")
        }
        XCTAssertEqual(systemReason, .systemLocation)

        let broken = "/Applications/Bad\nName.app"
        let brokenResult = plan(paths: [broken], kinds: [broken: .applicationBundle])
        guard case .failure(let brokenReason) = brokenResult else {
            return XCTFail("expected a rejection")
        }
        XCTAssertEqual(brokenReason, .escapesRoot)
    }

    func testRecognizesThePermissionErrorFromTrash() {
        XCTAssertTrue(TrashPermissions.isDenied(CocoaError(.fileWriteNoPermission)))
        XCTAssertFalse(TrashPermissions.isDenied(CocoaError(.fileNoSuchFile)))
    }

    private func plan(
        paths: [String],
        kinds: [String: TrashItemKind]
    ) -> Result<PrivilegedTrashPlan, RejectionReason> {
        PrivilegedTrashPlanner.plan(
            paths: paths,
            trashDirectory: "/Users/me/.Trash",
            userHome: "/Users/me",
            uid: 501,
            gid: 20,
            prompt: "Banish needs your password to move this app to the Trash.",
            authorization: TrashAuthorization(
                bundleIdentifiers: ["com.example.App"],
                permittedPaths: Set(paths),
                currentApplicationPath: nil
            ),
            kinds: kinds
        )
    }
}
