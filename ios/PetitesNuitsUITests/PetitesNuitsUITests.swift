import XCTest

/// Placeholder UI tests. Les véritables snapshots Fastlane seront
/// implémentés en Phase 2b avec un ScreenshotDataService.
@MainActor
final class PetitesNuitsUITests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        // TabView "Saisie" tab should be present at launch.
        XCTAssertTrue(app.tabBars.buttons["Saisie"].waitForExistence(timeout: 5))
    }
}
