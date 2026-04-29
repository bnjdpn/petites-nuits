import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("GraphiqueViewModel")
@MainActor
struct GraphiqueViewModelTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    @Test("Empty store yields empty data points")
    func emptyData() throws {
        let container = try makeContainer()
        let viewModel = GraphiqueViewModel(modelContext: container.mainContext)
        viewModel.refresh()
        #expect(viewModel.dataPoints.isEmpty)
    }

    @Test("Limit to 14 most recent nights")
    func limitFourteen() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        for offsetDays in 0..<20 {
            let bedtime = base.addingTimeInterval(TimeInterval(offsetDays) * 86_400)
            context.insert(NightEntry(bedtime: bedtime, wakeUpTime: bedtime.addingTimeInterval(8 * 3600)))
        }
        try context.save()

        let viewModel = GraphiqueViewModel(modelContext: context)
        viewModel.refresh()
        #expect(viewModel.dataPoints.count == 14)
    }

    // Risk #4 spec — secondary axis relative scaling
    @Test("Wake-ups secondary axis uses relative max for scaling", arguments: [
        ([0, 1, 2, 3], 3),
        ([5, 5, 5, 5], 5),
        ([0, 0, 0, 0], 1), // floor 1 to avoid divide-by-zero scaling
        ([2], 2)
    ])
    func secondaryAxisRelativeMax(wakeUpsCounts: [Int], expectedMax: Int) throws {
        let container = try makeContainer()
        let context = container.mainContext
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        for (idx, count) in wakeUpsCounts.enumerated() {
            let bedtime = base.addingTimeInterval(TimeInterval(idx) * 86_400)
            let wakeUps = (0..<count).map { _ in
                WakeUp(time: bedtime, durationMinutes: 5, isFeeding: false)
            }
            context.insert(NightEntry(
                bedtime: bedtime,
                wakeUpTime: bedtime.addingTimeInterval(8 * 3600),
                wakeUps: wakeUps
            ))
        }
        try context.save()

        let viewModel = GraphiqueViewModel(modelContext: context)
        viewModel.refresh()
        #expect(viewModel.maxWakeUpsRelative == expectedMax)
    }

    @Test("Data points expose hours of duration")
    func durationHoursMapping() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let bedtime = Date(timeIntervalSince1970: 1_700_000_000)
        context.insert(NightEntry(
            bedtime: bedtime,
            wakeUpTime: bedtime.addingTimeInterval(8 * 3600 + 30 * 60)
        ))
        try context.save()
        let viewModel = GraphiqueViewModel(modelContext: context)
        viewModel.refresh()
        let point = try #require(viewModel.dataPoints.first)
        #expect(abs(point.durationHours - 8.5) < 0.001)
    }
}
