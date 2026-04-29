import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("SaisieViewModel edit mode")
@MainActor
struct SaisieEditModeTests {
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
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }

    @Test("init(editing:) prefills bedtime, wakeUpTime, mood, wakeUps, notes")
    func editInitPrefills() throws {
        let container = try makeContainer()
        let bed = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        let wake = makeDate(year: 2026, month: 4, day: 29, hour: 7)
        let entry = NightEntry(
            bedtime: bed,
            wakeUpTime: wake,
            wakeUps: [WakeUp(time: bed, durationMinutes: 15, isFeeding: true)],
            mood: .good,
            notes: "lampe douce"
        )
        container.mainContext.insert(entry)
        try container.mainContext.save()

        let viewModel = SaisieViewModel(modelContext: container.mainContext, editing: entry)
        #expect(viewModel.bedtime == bed)
        #expect(viewModel.wakeUpTime == wake)
        #expect(viewModel.mood == .good)
        #expect(viewModel.notes == "lampe douce")
        #expect(viewModel.wakeUps.count == 1)
        #expect(viewModel.isEditing == true)
    }

    @Test("init() without editing keeps create mode")
    func createMode() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        #expect(viewModel.isEditing == false)
    }

    @Test("save() in edit mode updates the existing entry (no new insert)")
    func editSaveUpdates() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let entry = NightEntry(
            bedtime: makeDate(year: 2026, month: 4, day: 28, hour: 22),
            wakeUpTime: makeDate(year: 2026, month: 4, day: 29, hour: 7),
            mood: .ok,
            notes: "v1"
        )
        context.insert(entry)
        try context.save()

        let viewModel = SaisieViewModel(modelContext: context, editing: entry)
        viewModel.notes = "v2"
        viewModel.mood = .great
        try viewModel.save()

        let descriptor = FetchDescriptor<NightEntry>()
        let entries = try context.fetch(descriptor)
        #expect(entries.count == 1) // not duplicated
        let stored = try #require(entries.first)
        #expect(stored.notes == "v2")
        #expect(stored.mood == .great)
        #expect(stored.id == entry.id)
    }

    @Test("delete() in edit mode removes the entry")
    func editDeleteRemoves() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let entry = NightEntry(
            bedtime: makeDate(year: 2026, month: 4, day: 28, hour: 22),
            wakeUpTime: makeDate(year: 2026, month: 4, day: 29, hour: 7)
        )
        context.insert(entry)
        try context.save()

        let viewModel = SaisieViewModel(modelContext: context, editing: entry)
        try viewModel.deleteEditedEntry()

        let descriptor = FetchDescriptor<NightEntry>()
        let entries = try context.fetch(descriptor)
        #expect(entries.isEmpty)
    }

    @Test("delete() in create mode throws (no entry to delete)")
    func deleteInCreateModeThrows() throws {
        let container = try makeContainer()
        let viewModel = SaisieViewModel(modelContext: container.mainContext)
        #expect(throws: SaisieViewModel.EditError.notInEditMode) {
            try viewModel.deleteEditedEntry()
        }
    }
}
