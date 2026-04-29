import XCTest

/// Placeholder UI tests Phase 1. Les véritables snapshots Fastlane seront
/// implémentés en Phase 2 quand les écrans existent.
final class PetitesNuitsUITests: XCTestCase {
    func testAppLaunches() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Petites Nuits"].waitForExistence(timeout: 5))
    }
}
