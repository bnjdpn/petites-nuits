import XCTest

/// UI test exécuté par fastlane snapshot. Navigue les 5 onglets et capture
/// un screenshot par onglet. Les données sont seedées par le launch arg
/// `-screenshot` qui active `ScreenshotDataService` côté app.
@MainActor
final class PetitesNuitsScreenshotsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testTakeScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-screenshot"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))

        // 1. Saisie (default tab)
        snapshot("01-Saisie")

        // 2. Calendrier
        if tabBar.buttons["Calendrier"].exists {
            tabBar.buttons["Calendrier"].tap()
            sleep(1)
            snapshot("02-Calendrier")
        }

        // 3. Graphique
        if tabBar.buttons["Graphique"].exists {
            tabBar.buttons["Graphique"].tap()
            sleep(1)
            snapshot("03-Graphique")
        }

        // 4. Tableau
        if tabBar.buttons["Tableau"].exists {
            tabBar.buttons["Tableau"].tap()
            sleep(1)
            snapshot("04-Tableau")
        }

        // 5. Stats
        if tabBar.buttons["Stats"].exists {
            tabBar.buttons["Stats"].tap()
            sleep(1)
            snapshot("05-Stats")
        }
    }
}
