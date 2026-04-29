import Foundation
import SwiftData
import Testing
@testable import PetitesNuits

@Suite("NightNotifications broadcast")
@MainActor
struct NightNotificationsTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: NightEntry.self, configurations: config)
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.timeZone = TimeZone(identifier: "Europe/Paris")
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }

    /// Petit accumulateur thread-safe pour observer un compteur dans une
    /// closure `@Sendable` sans warning Swift 6.
    private final class Counter: @unchecked Sendable {
        private var value = 0
        private let lock = NSLock()
        func increment() {
            lock.lock(); defer { lock.unlock() }
            value += 1
        }
        var current: Int {
            lock.lock(); defer { lock.unlock() }
            return value
        }
    }

    @Test("save() posts NightNotifications.saved on the injected center")
    func saveBroadcastsSaved() throws {
        let container = try makeContainer()
        let center = NotificationCenter()
        let viewModel = SaisieViewModel(
            modelContext: container.mainContext,
            notificationCenter: center
        )
        viewModel.bedtime = makeDate(year: 2026, month: 4, day: 28, hour: 22)
        viewModel.wakeUpTime = makeDate(year: 2026, month: 4, day: 29, hour: 7)

        let counter = Counter()
        let token = center.addObserver(
            forName: NightNotifications.saved,
            object: nil,
            queue: nil
        ) { _ in
            counter.increment()
        }
        defer { center.removeObserver(token) }

        try viewModel.save()
        #expect(counter.current == 1)
    }

    @Test("TableauViewModel.delete posts NightNotifications.deleted")
    func deleteBroadcastsDeleted() throws {
        let container = try makeContainer()
        let center = NotificationCenter()
        let context = container.mainContext
        let entry = NightEntry(
            bedtime: makeDate(year: 2026, month: 4, day: 28, hour: 22),
            wakeUpTime: makeDate(year: 2026, month: 4, day: 29, hour: 7)
        )
        context.insert(entry)
        try context.save()

        let viewModel = TableauViewModel(
            modelContext: context,
            notificationCenter: center
        )
        viewModel.refresh()

        let counter = Counter()
        let token = center.addObserver(
            forName: NightNotifications.deleted,
            object: nil,
            queue: nil
        ) { _ in
            counter.increment()
        }
        defer { center.removeObserver(token) }

        try viewModel.delete(entry: entry)
        #expect(counter.current == 1)
    }

    @Test("CalendrierViewModel.observeNightChanges triggers refresh on saved")
    func calendrierObservesSaved() async throws {
        let container = try makeContainer()
        let center = NotificationCenter()
        let context = container.mainContext

        let viewModel = CalendrierViewModel(
            modelContext: context,
            notificationCenter: center
        )
        viewModel.refresh()
        #expect(viewModel.entries.isEmpty)

        let task = Task { await viewModel.observeNightChanges() }
        // Yield to let the observer subscribe before posting.
        try await Task.sleep(nanoseconds: 50_000_000)

        let entry = NightEntry(
            bedtime: makeDate(year: Calendar.current.component(.year, from: Date()),
                              month: Calendar.current.component(.month, from: Date()),
                              day: 1, hour: 22),
            wakeUpTime: makeDate(year: Calendar.current.component(.year, from: Date()),
                                 month: Calendar.current.component(.month, from: Date()),
                                 day: 2, hour: 7)
        )
        context.insert(entry)
        try context.save()
        center.post(name: NightNotifications.saved, object: nil)

        try await Task.sleep(nanoseconds: 100_000_000)
        task.cancel()
        #expect(viewModel.entries.count == 1)
    }

    @Test("StatsViewModel.observeNightChanges triggers refresh on saved")
    func statsObservesSaved() async throws {
        let container = try makeContainer()
        let center = NotificationCenter()
        let context = container.mainContext

        let viewModel = StatsViewModel(
            modelContext: context,
            notificationCenter: center
        )
        viewModel.refresh()
        #expect(viewModel.totalNights == 0)

        let task = Task { await viewModel.observeNightChanges() }
        try await Task.sleep(nanoseconds: 50_000_000)

        context.insert(NightEntry(
            bedtime: makeDate(year: 2026, month: 4, day: 28, hour: 22),
            wakeUpTime: makeDate(year: 2026, month: 4, day: 29, hour: 7)
        ))
        try context.save()
        center.post(name: NightNotifications.saved, object: nil)

        try await Task.sleep(nanoseconds: 100_000_000)
        task.cancel()
        #expect(viewModel.totalNights == 1)
    }

    @Test("TableauViewModel observes deleted (refresh on delete signal)")
    func tableauObservesDeleted() async throws {
        let container = try makeContainer()
        let center = NotificationCenter()
        let context = container.mainContext
        let entry = NightEntry(
            bedtime: makeDate(year: 2026, month: 4, day: 28, hour: 22),
            wakeUpTime: makeDate(year: 2026, month: 4, day: 29, hour: 7)
        )
        context.insert(entry)
        try context.save()

        let viewModel = TableauViewModel(
            modelContext: context,
            notificationCenter: center
        )
        viewModel.refresh()
        #expect(viewModel.entries.count == 1)

        let task = Task { await viewModel.observeNightChanges() }
        try await Task.sleep(nanoseconds: 50_000_000)

        context.delete(entry)
        try context.save()
        center.post(name: NightNotifications.deleted, object: nil)

        try await Task.sleep(nanoseconds: 100_000_000)
        task.cancel()
        #expect(viewModel.entries.isEmpty)
    }
}
