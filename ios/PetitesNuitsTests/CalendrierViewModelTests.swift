import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("CalendrierViewModel")
@MainActor
struct CalendrierViewModelTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    private func parisCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        calendar.firstWeekday = 2 // Monday
        return calendar
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 22) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.timeZone = TimeZone(identifier: "Europe/Paris")
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    @Test("Default selected month is current month")
    func defaultMonth() throws {
        let container = try makeContainer()
        let viewModel = CalendrierViewModel(modelContext: container.mainContext, calendar: parisCalendar())
        let now = Date()
        let calendar = parisCalendar()
        #expect(calendar.component(.month, from: viewModel.selectedMonth) == calendar.component(.month, from: now))
    }

    @Test("nextMonth/previousMonth navigates by one month")
    func navigateMonths() throws {
        let container = try makeContainer()
        let viewModel = CalendrierViewModel(modelContext: container.mainContext, calendar: parisCalendar())
        let initial = viewModel.selectedMonth
        viewModel.nextMonth()
        let calendar = parisCalendar()
        let diff = calendar.dateComponents([.month], from: initial, to: viewModel.selectedMonth).month ?? 0
        #expect(diff == 1)
        viewModel.previousMonth()
        viewModel.previousMonth()
        let diff2 = calendar.dateComponents([.month], from: initial, to: viewModel.selectedMonth).month ?? 0
        #expect(diff2 == -1)
    }

    // Risk #3 spec — Monday-first FR offset
    @Test("Monday-first offset for first week of month", arguments: [
        // (year, month, expectedOffset Mon=0..Sun=6 of the 1st)
        (2026, 1, 3),  // 2026-01-01 = Thursday → offset 3
        (2026, 9, 1),  // 2026-09-01 = Tuesday → offset 1
        (2026, 11, 6), // 2026-11-01 = Sunday → offset 6
        (2026, 6, 0),  // 2026-06-01 = Monday → offset 0
        (2026, 4, 2)   // 2026-04-01 = Wednesday → offset 2
    ])
    func mondayFirstOffset(year: Int, month: Int, expected: Int) throws {
        let container = try makeContainer()
        let viewModel = CalendrierViewModel(modelContext: container.mainContext, calendar: parisCalendar())
        viewModel.selectedMonth = makeDate(year: year, month: month, day: 1, hour: 12)
        #expect(viewModel.firstDayOffsetMondayFirst == expected)
    }

    @Test("Days in month for various months")
    func daysInMonth() throws {
        let container = try makeContainer()
        let viewModel = CalendrierViewModel(modelContext: container.mainContext, calendar: parisCalendar())
        viewModel.selectedMonth = makeDate(year: 2026, month: 2, day: 1)
        #expect(viewModel.daysInMonth == 28)
        viewModel.selectedMonth = makeDate(year: 2024, month: 2, day: 1)
        #expect(viewModel.daysInMonth == 29) // leap
        viewModel.selectedMonth = makeDate(year: 2026, month: 4, day: 1)
        #expect(viewModel.daysInMonth == 30)
        viewModel.selectedMonth = makeDate(year: 2026, month: 1, day: 1)
        #expect(viewModel.daysInMonth == 31)
    }

    @Test("Entries for selected month filters out other months")
    func entriesForSelectedMonthFilters() throws {
        let container = try makeContainer()
        let context = container.mainContext
        // April 28 entry
        context.insert(NightEntry(
            bedtime: makeDate(year: 2026, month: 4, day: 28),
            wakeUpTime: makeDate(year: 2026, month: 4, day: 29, hour: 7)
        ))
        // March 15 entry
        context.insert(NightEntry(
            bedtime: makeDate(year: 2026, month: 3, day: 15),
            wakeUpTime: makeDate(year: 2026, month: 3, day: 16, hour: 7)
        ))
        try context.save()

        let viewModel = CalendrierViewModel(modelContext: context, calendar: parisCalendar())
        viewModel.selectedMonth = makeDate(year: 2026, month: 4, day: 10)
        viewModel.refresh()
        #expect(viewModel.entries.count == 1)
    }
}
