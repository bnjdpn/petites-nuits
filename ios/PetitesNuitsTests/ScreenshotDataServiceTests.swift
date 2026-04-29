import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("ScreenshotDataService")
@MainActor
struct ScreenshotDataServiceTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    @Test("seedIfNeeded inserts the fixture nights when store is empty")
    func seedsEmptyStore() throws {
        let container = try makeContainer()
        ScreenshotDataService.seedIfNeeded(modelContext: container.mainContext)
        let descriptor = FetchDescriptor<NightEntry>()
        let entries = try container.mainContext.fetch(descriptor)
        #expect(entries.count == 7)
    }

    @Test("seedIfNeeded is idempotent when store already has entries")
    func idempotent() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        context.insert(NightEntry(bedtime: date, wakeUpTime: date.addingTimeInterval(8 * 3600)))
        try context.save()

        ScreenshotDataService.seedIfNeeded(modelContext: context)
        let descriptor = FetchDescriptor<NightEntry>()
        let entries = try context.fetch(descriptor)
        #expect(entries.count == 1)
    }

    @Test("Fixture covers extreme moods to demo the heatmap palette")
    func fixtureCoversExtremes() {
        let entries = ScreenshotDataService.makeFixtureEntries(now: Date())
        let moods = Set(entries.map(\.mood))
        #expect(moods.contains(.great))
        #expect(moods.contains(.terrible))
    }
}
