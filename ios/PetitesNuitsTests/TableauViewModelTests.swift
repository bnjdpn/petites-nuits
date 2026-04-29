import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("TableauViewModel")
@MainActor
struct TableauViewModelTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    @Test("Empty store yields empty rows")
    func emptyRows() throws {
        let container = try makeContainer()
        let viewModel = TableauViewModel(modelContext: container.mainContext)
        viewModel.refresh()
        #expect(viewModel.entries.isEmpty)
    }

    @Test("Entries sorted by bedtime descending")
    func sortDescending() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let dates = [base, base.addingTimeInterval(86_400), base.addingTimeInterval(2 * 86_400)]
        for date in dates {
            context.insert(NightEntry(bedtime: date, wakeUpTime: date.addingTimeInterval(8 * 3600)))
        }
        try context.save()

        let viewModel = TableauViewModel(modelContext: context)
        viewModel.refresh()
        #expect(viewModel.entries.count == 3)
        #expect(viewModel.entries[0].bedtime == dates[2])
        #expect(viewModel.entries[2].bedtime == dates[0])
    }

    @Test("Delete removes from store and refreshes list")
    func deleteEntry() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = NightEntry(bedtime: base, wakeUpTime: base.addingTimeInterval(8 * 3600))
        context.insert(entry)
        try context.save()

        let viewModel = TableauViewModel(modelContext: context)
        viewModel.refresh()
        #expect(viewModel.entries.count == 1)
        try viewModel.delete(entry: entry)
        #expect(viewModel.entries.isEmpty)
    }
}
