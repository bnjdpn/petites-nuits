import SwiftData
import SwiftUI

@main
struct PetitesNuitsApp: App {
    let modelContainer: ModelContainer
    private let isScreenshotMode: Bool

    init() {
        let schema = Schema([NightEntry.self])
        #if DEBUG
        let isScreenshot = ProcessInfo.processInfo.arguments.contains("-screenshot")
        #else
        let isScreenshot = false
        #endif
        self.isScreenshotMode = isScreenshot

        do {
            if isScreenshot {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                self.modelContainer = try ModelContainer(for: schema, configurations: config)
            } else {
                let config = ModelConfiguration()
                self.modelContainer = try ModelContainer(for: schema, configurations: config)
            }
        } catch {
            fatalError("Échec d'initialisation du ModelContainer : \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    if isScreenshotMode {
                        await MainActor.run {
                            ScreenshotDataService.seedIfNeeded(modelContext: modelContainer.mainContext)
                        }
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
