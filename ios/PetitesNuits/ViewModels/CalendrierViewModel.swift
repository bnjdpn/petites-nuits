import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Calendrier". Gère le mois sélectionné, la liste
/// d'entrées du mois, et expose les helpers grid lundi-first FR (risk #3).
@MainActor
@Observable
final class CalendrierViewModel {
    private let modelContext: ModelContext
    private let calendar: Calendar

    var selectedMonth: Date
    private(set) var entries: [NightEntry] = []

    init(modelContext: ModelContext, calendar: Calendar = .autoupdatingCurrent, now: Date = .now) {
        self.modelContext = modelContext
        var cal = calendar
        cal.firstWeekday = 2 // Monday — locale FR
        self.calendar = cal
        // Force selectedMonth = first of current month
        let components = cal.dateComponents([.year, .month], from: now)
        self.selectedMonth = cal.date(from: components) ?? now
    }

    // MARK: - Navigation

    func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = next
            refresh()
        }
    }

    func previousMonth() {
        if let previous = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = previous
            refresh()
        }
    }

    // MARK: - Grid helpers (risk #3 — lundi-first offset)

    /// Offset (0..6) du 1er du mois en grille lundi-first.
    /// Lundi = 0, Mardi = 1, ... Dimanche = 6.
    var firstDayOffsetMondayFirst: Int {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return 0 }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        // weekday : 1 = Sunday ... 7 = Saturday (Gregorian)
        // Monday-first : Mon=0, Tue=1, ... Sun=6
        return (weekday + 5) % 7
    }

    var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 0
    }

    // MARK: - Data fetching

    func refresh() {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let monthStart = calendar.date(from: components),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            entries = []
            return
        }
        let predicate = #Predicate<NightEntry> { entry in
            entry.bedtime >= monthStart && entry.bedtime < monthEnd
        }
        let descriptor = FetchDescriptor<NightEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.bedtime, order: .reverse)]
        )
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Retourne l'entrée pour un jour donné (1..daysInMonth) ou nil.
    func entry(forDay day: Int) -> NightEntry? {
        var components = calendar.dateComponents([.year, .month], from: selectedMonth)
        components.day = day
        guard let dayStart = calendar.date(from: components),
              let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return nil
        }
        return entries.first { $0.bedtime >= dayStart && $0.bedtime < dayEnd }
    }
}
