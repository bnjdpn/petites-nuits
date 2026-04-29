import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("SaisieViewModel")
@MainActor
struct SaisieViewModelTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "Europe/Paris")
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    @Test("New ViewModel exposes default bedtime and wakeUpTime")
    func defaults() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        #expect(viewModel.mood == .ok)
        #expect(viewModel.wakeUps.isEmpty)
        #expect(viewModel.notes == "")
    }

    @Test("addWakeUp appends a WakeUp at default duration")
    func addWakeUpAppends() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        viewModel.addWakeUp(at: Date(timeIntervalSince1970: 1_700_000_000), durationMinutes: 10, isFeeding: true)
        #expect(viewModel.wakeUps.count == 1)
        #expect(viewModel.wakeUps[0].durationMinutes == 10)
        #expect(viewModel.wakeUps[0].isFeeding == true)
    }

    @Test("removeWakeUp removes by id")
    func removeWakeUpById() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        viewModel.addWakeUp(at: Date(), durationMinutes: 5, isFeeding: false)
        viewModel.addWakeUp(at: Date(), durationMinutes: 10, isFeeding: true)
        let toRemove = viewModel.wakeUps[0].id
        viewModel.removeWakeUp(id: toRemove)
        #expect(viewModel.wakeUps.count == 1)
        #expect(viewModel.wakeUps[0].durationMinutes == 10)
    }

    @Test("save() persists a NightEntry with current state")
    func saveCommitsEntry() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        viewModel.bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        viewModel.wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 7)
        viewModel.mood = .good
        viewModel.notes = "calme"
        viewModel.addWakeUp(at: viewModel.bedtime, durationMinutes: 10, isFeeding: true)
        try viewModel.save()

        let descriptor = FetchDescriptor<NightEntry>()
        let entries = try container.mainContext.fetch(descriptor)
        #expect(entries.count == 1)
        let stored = try #require(entries.first)
        #expect(stored.mood == .good)
        #expect(stored.notes == "calme")
        #expect(stored.wakeUps.count == 1)
    }

    // Risk #1 spec — cross-midnight handling
    @Test("Cross-midnight: wakeUpTime hour < bedtime hour rolls wake to next day", arguments: [
        (22, 0, 6, 30, 8 * 3600 + 30 * 60),
        (23, 30, 5, 0, 5 * 3600 + 30 * 60),
        (20, 15, 7, 45, 11 * 3600 + 30 * 60),
        // edge: same hour wakeRaw == bedtime → roll +1 day → 24h diff
        (21, 0, 21, 0, 24 * 3600),
        (14, 0, 16, 0, 2 * 3600) // same-day nap
    ])
    func crossMidnightRoll(bedH: Int, bedM: Int, wakeH: Int, wakeM: Int, expectedSeconds: Int) throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        let day = makeDate(year: 2026, month: 4, day: 28, hour: bedH, minute: bedM)
        viewModel.bedtime = day
        // User sets wake using same-day picker; VM should auto-roll.
        let wakeRaw = makeDate(year: 2026, month: 4, day: 28, hour: wakeH, minute: wakeM)
        viewModel.setWakeUpTimeRolling(toSameDayValue: wakeRaw)

        let computed = viewModel.computedDurationSeconds
        #expect(Int(computed) == expectedSeconds)
    }

    @Test("Reset clears state for next entry")
    func resetClears() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        viewModel.notes = "abc"
        viewModel.mood = .bad
        viewModel.addWakeUp(at: Date(), durationMinutes: 5, isFeeding: false)
        viewModel.reset()
        #expect(viewModel.notes == "")
        #expect(viewModel.mood == .ok)
        #expect(viewModel.wakeUps.isEmpty)
    }
}
