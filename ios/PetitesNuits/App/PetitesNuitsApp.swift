import SwiftData
import SwiftUI

@main
struct PetitesNuitsApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([NightEntry.self])
        do {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-screenshot") {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                self.modelContainer = try ModelContainer(for: schema, configurations: config)
                return
            }
            #endif
            let config = ModelConfiguration()
            self.modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Échec d'initialisation du ModelContainer : \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
