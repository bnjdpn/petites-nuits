import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("NightEntry")
struct NightEntryTests {
    // MARK: - Helpers

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

    // MARK: - Computed properties

    @Test("sleepDurationSeconds equals wakeUpTime - bedtime")
    func sleepDurationBasic() {
        let bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        let wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 7)
        let entry = NightEntry(bedtime: bedtime, wakeUpTime: wakeUpTime)
        #expect(entry.sleepDurationSeconds == 9 * 3600)
    }

    @Test("Cross-midnight sleep duration is positive")
    func crossMidnightDuration() {
        // Bedtime 23:30 → wakeUp 06:15 next day = 6h45m = 24300 sec
        let bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 23, minute: 30)
        let wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 6, minute: 15)
        let entry = NightEntry(bedtime: bedtime, wakeUpTime: wakeUpTime)
        #expect(entry.sleepDurationSeconds == 6 * 3600 + 45 * 60)
    }

    @Test("Same-day nap (bedtime 14:00, wake 16:30) computes correctly")
    func sameDayNap() {
        let bedtime = makeDate(year: 2026, month: 4, day: 29, hour: 14)
        let wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 16, minute: 30)
        let entry = NightEntry(bedtime: bedtime, wakeUpTime: wakeUpTime)
        #expect(entry.sleepDurationSeconds == 2 * 3600 + 30 * 60)
    }

    @Test("totalWakeUpSeconds sums durationMinutes * 60 across wakeUps")
    func totalWakeUpSecondsSum() {
        let bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        let wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 7)
        let entry = NightEntry(
            bedtime: bedtime,
            wakeUpTime: wakeUpTime,
            wakeUps: [
                WakeUp(time: bedtime, durationMinutes: 10, isFeeding: false),
                WakeUp(time: bedtime, durationMinutes: 25, isFeeding: true),
                WakeUp(time: bedtime, durationMinutes: 5, isFeeding: false)
            ]
        )
        #expect(entry.totalWakeUpSeconds == TimeInterval(40 * 60))
    }

    @Test("effectiveSleepSeconds subtracts wakeUps and never goes below zero")
    func effectiveSleepClampedZero() {
        let bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        let wakeUpTime = makeDate(year: 2026, month: 4, day: 28, hour: 22, minute: 30) // 30min nap
        let entry = NightEntry(
            bedtime: bedtime,
            wakeUpTime: wakeUpTime,
            wakeUps: [WakeUp(time: bedtime, durationMinutes: 60, isFeeding: false)] // 60min wake
        )
        #expect(entry.effectiveSleepSeconds == 0)
    }

    @Test("feedingCount counts wakeUps where isFeeding == true")
    func feedingCount() {
        let bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        let wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 7)
        let entry = NightEntry(
            bedtime: bedtime,
            wakeUpTime: wakeUpTime,
            wakeUps: [
                WakeUp(time: bedtime, durationMinutes: 5, isFeeding: false),
                WakeUp(time: bedtime, durationMinutes: 20, isFeeding: true),
                WakeUp(time: bedtime, durationMinutes: 15, isFeeding: true)
            ]
        )
        #expect(entry.feedingCount == 2)
    }

    @Test("formatDuration renders Xh00 with leading-zero minutes", arguments: [
        (9 * 3600, "9h00"),
        (8 * 3600 + 30 * 60, "8h30"),
        (7 * 3600 + 5 * 60, "7h05"),
        (12 * 3600 + 0 * 60, "12h00")
    ])
    func formatDurationVariants(seconds: Int, expected: String) {
        let bedtime = Date(timeIntervalSince1970: 0)
        let wakeUpTime = bedtime.addingTimeInterval(TimeInterval(seconds))
        let entry = NightEntry(bedtime: bedtime, wakeUpTime: wakeUpTime)
        #expect(entry.formatDuration() == expected)
    }

    @Test("formatEffectiveDuration takes wakeUps into account")
    func formatEffectiveDuration() {
        let bedtime = Date(timeIntervalSince1970: 0)
        let wakeUpTime = bedtime.addingTimeInterval(8 * 3600) // 8h
        let entry = NightEntry(
            bedtime: bedtime,
            wakeUpTime: wakeUpTime,
            wakeUps: [WakeUp(time: bedtime, durationMinutes: 30, isFeeding: false)]
        )
        // 8h - 30min = 7h30
        #expect(entry.formatEffectiveDuration() == "7h30")
    }

    // MARK: - SwiftData round-trip

    @Test("Insert and fetch NightEntry round-trip preserves wakeUps array")
    @MainActor
    func swiftDataRoundTrip() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: NightEntry.self, configurations: config)
        let context = container.mainContext

        let bedtime = Date(timeIntervalSince1970: 1_700_000_000)
        let wakeUpTime = bedtime.addingTimeInterval(8 * 3600)
        let entry = NightEntry(
            bedtime: bedtime,
            wakeUpTime: wakeUpTime,
            wakeUps: [
                WakeUp(time: bedtime.addingTimeInterval(3600), durationMinutes: 10, isFeeding: true, note: "tétée"),
                WakeUp(time: bedtime.addingTimeInterval(7200), durationMinutes: 5, isFeeding: false)
            ],
            mood: .good,
            notes: "bonne nuit"
        )
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<NightEntry>())
        #expect(fetched.count == 1)
        let restored = try #require(fetched.first)
        #expect(restored.bedtime == bedtime)
        #expect(restored.wakeUpTime == wakeUpTime)
        #expect(restored.wakeUps.count == 2)
        #expect(restored.wakeUps[0].isFeeding == true)
        #expect(restored.wakeUps[0].note == "tétée")
        #expect(restored.wakeUps[0].durationMinutes == 10)
        #expect(restored.mood == .good)
        #expect(restored.notes == "bonne nuit")
        #expect(restored.feedingCount == 1)
    }

    @Test("Empty wakeUps array round-trips correctly")
    @MainActor
    func emptyWakeUpsRoundTrip() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: NightEntry.self, configurations: config)
        let context = container.mainContext

        let entry = NightEntry(
            bedtime: Date(timeIntervalSince1970: 1_700_000_000),
            wakeUpTime: Date(timeIntervalSince1970: 1_700_000_000 + 8 * 3600)
        )
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<NightEntry>())
        let restored = try #require(fetched.first)
        #expect(restored.wakeUps.isEmpty)
        #expect(restored.feedingCount == 0)
        #expect(restored.totalWakeUpSeconds == 0)
        #expect(restored.mood == .ok) // default
        #expect(restored.notes == "")
    }

    @Test("Sort by bedtime descending fetches most recent first")
    @MainActor
    func sortByBedtimeDescending() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: NightEntry.self, configurations: config)
        let context = container.mainContext

        let dates: [Date] = [
            Date(timeIntervalSince1970: 1_700_000_000),
            Date(timeIntervalSince1970: 1_700_086_400),
            Date(timeIntervalSince1970: 1_700_172_800)
        ]
        for date in dates {
            context.insert(NightEntry(bedtime: date, wakeUpTime: date.addingTimeInterval(8 * 3600)))
        }
        try context.save()

        let descriptor = FetchDescriptor<NightEntry>(sortBy: [SortDescriptor(\.bedtime, order: .reverse)])
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 3)
        #expect(fetched[0].bedtime == dates[2])
        #expect(fetched[2].bedtime == dates[0])
    }

    @Test("Delete removes entry from store")
    @MainActor
    func deleteEntry() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: NightEntry.self, configurations: config)
        let context = container.mainContext

        let entry = NightEntry(
            bedtime: Date(timeIntervalSince1970: 1_700_000_000),
            wakeUpTime: Date(timeIntervalSince1970: 1_700_000_000 + 8 * 3600)
        )
        context.insert(entry)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<NightEntry>()) == 1)

        context.delete(entry)
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<NightEntry>()) == 0)
    }
}
