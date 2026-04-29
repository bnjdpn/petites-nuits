import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("StatsViewModel")
@MainActor
struct StatsViewModelTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    @Test("Empty store yields nil averages and zero count")
    func emptyStore() throws {
        let container = try makeContainer()
        let viewModel = StatsViewModel(modelContext: container.mainContext)
        viewModel.refresh()
        #expect(viewModel.totalNights == 0)
        #expect(viewModel.averageDurationSeconds == nil)
        #expect(viewModel.averageWakeUpsPerNight == nil)
    }

    @Test("Averages over a fixed dataset")
    func averages() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        // 3 nights: 8h, 7h, 9h → avg 8h. Wake-ups: 1, 2, 3 → avg 2
        let durations = [8, 7, 9]
        for (idx, hours) in durations.enumerated() {
            let bedtime = base.addingTimeInterval(TimeInterval(idx) * 86_400)
            let wakeUpsArr = (0..<(idx + 1)).map { _ in
                WakeUp(time: bedtime, durationMinutes: 5, isFeeding: false)
            }
            context.insert(NightEntry(
                bedtime: bedtime,
                wakeUpTime: bedtime.addingTimeInterval(TimeInterval(hours) * 3600),
                wakeUps: wakeUpsArr
            ))
        }
        try context.save()

        let viewModel = StatsViewModel(modelContext: context)
        viewModel.refresh()
        #expect(viewModel.totalNights == 3)
        let avgSec = try #require(viewModel.averageDurationSeconds)
        #expect(abs(avgSec - 8 * 3600) < 1)
        let avgWake = try #require(viewModel.averageWakeUpsPerNight)
        #expect(abs(avgWake - 2.0) < 0.001)
    }

    @Test("Trend computes 7d vs previous 7d delta", arguments: [
        // (recent7Avg, previous7Avg, expectedTrend)
        (8.0, 7.0, StatsViewModel.Trend.improving),
        (6.0, 8.0, StatsViewModel.Trend.declining),
        (8.0, 8.0, StatsViewModel.Trend.stable),
        (8.05, 8.0, StatsViewModel.Trend.stable) // <2% delta = stable
    ])
    func trendComputation(recentHours: Double, previousHours: Double, expected: StatsViewModel.Trend) throws {
        let container = try makeContainer()
        let context = container.mainContext
        let now = Date()
        // Recent 7 nights
        for offset in 0..<7 {
            let bedtime = now.addingTimeInterval(-TimeInterval(offset) * 86_400)
            context.insert(NightEntry(
                bedtime: bedtime,
                wakeUpTime: bedtime.addingTimeInterval(recentHours * 3600)
            ))
        }
        // Previous 7 nights
        for offset in 7..<14 {
            let bedtime = now.addingTimeInterval(-TimeInterval(offset) * 86_400)
            context.insert(NightEntry(
                bedtime: bedtime,
                wakeUpTime: bedtime.addingTimeInterval(previousHours * 3600)
            ))
        }
        try context.save()

        let viewModel = StatsViewModel(modelContext: context)
        viewModel.refresh()
        #expect(viewModel.trend == expected)
    }
}
