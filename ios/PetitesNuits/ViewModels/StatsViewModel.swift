import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Stats". Aggregations sur l'ensemble du store +
/// tendance 7j vs 7j précédents. Observe `NightNotifications` pour se
/// rafraîchir quand une nuit est ajoutée / modifiée / supprimée.
@MainActor
@Observable
final class StatsViewModel {
    enum Trend: Equatable, Sendable {
        case improving
        case declining
        case stable
    }

    private let modelContext: ModelContext
    private let notificationCenter: NotificationCenter

    private(set) var totalNights: Int = 0
    private(set) var averageDurationSeconds: TimeInterval?
    private(set) var averageWakeUpsPerNight: Double?
    private(set) var trend: Trend = .stable

    /// Seuil minimal pour considérer une variation comme "significative".
    /// 2% — sous ce delta on reste sur `.stable`.
    private let stableThresholdRatio = 0.02

    init(modelContext: ModelContext, notificationCenter: NotificationCenter = .default) {
        self.modelContext = modelContext
        self.notificationCenter = notificationCenter
    }

    func refresh() {
        let descriptor = FetchDescriptor<NightEntry>(
            sortBy: [SortDescriptor(\.bedtime, order: .reverse)]
        )
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        totalNights = entries.count

        guard !entries.isEmpty else {
            averageDurationSeconds = nil
            averageWakeUpsPerNight = nil
            trend = .stable
            return
        }

        let totalSeconds = entries.reduce(0.0) { $0 + $1.sleepDurationSeconds }
        averageDurationSeconds = totalSeconds / Double(entries.count)

        let totalWakeUps = entries.reduce(0) { $0 + $1.wakeUps.count }
        averageWakeUpsPerNight = Double(totalWakeUps) / Double(entries.count)

        trend = computeTrend(from: entries)
    }

    private func computeTrend(from entries: [NightEntry]) -> Trend {
        // entries sont triées DESC ; recent7 = 7 premières, previous7 = 7 suivantes
        let recent = Array(entries.prefix(7))
        let previous = Array(entries.dropFirst(7).prefix(7))
        guard !recent.isEmpty, !previous.isEmpty else { return .stable }

        let recentAvg = average(durations: recent)
        let previousAvg = average(durations: previous)

        guard previousAvg > 0 else { return .stable }
        let delta = (recentAvg - previousAvg) / previousAvg
        if abs(delta) < stableThresholdRatio { return .stable }
        return delta > 0 ? .improving : .declining
    }

    private func average(durations entries: [NightEntry]) -> Double {
        let total = entries.reduce(0.0) { $0 + $1.sleepDurationSeconds }
        return total / Double(entries.count)
    }

    /// Observe les notifications de cycle de vie d'une `NightEntry` et
    /// rafraîchit les stats à chaque émission. À appeler depuis `.task {}`.
    func observeNightChanges() async {
        for await _ in NightNotifications.merged(on: notificationCenter) {
            if Task.isCancelled { return }
            refresh()
        }
    }
}
