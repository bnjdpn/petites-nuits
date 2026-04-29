import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Graphique". Charge les 14 dernières nuits et
/// expose `dataPoints` (BarMark durée + PointMark réveils) + un max relatif
/// pour l'axe secondaire (risk #4 spec §5).
@MainActor
@Observable
final class GraphiqueViewModel {
    struct DataPoint: Identifiable, Hashable {
        let id: UUID
        let date: Date
        let durationHours: Double
        let effectiveDurationHours: Double
        let wakeUpsCount: Int
    }

    private let modelContext: ModelContext

    private(set) var dataPoints: [DataPoint] = []
    private(set) var maxWakeUpsRelative: Int = 1

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func refresh() {
        var descriptor = FetchDescriptor<NightEntry>(
            sortBy: [SortDescriptor(\.bedtime, order: .reverse)]
        )
        descriptor.fetchLimit = 14
        let fetched = (try? modelContext.fetch(descriptor)) ?? []

        // Affichage chronologique ascendant (gauche → droite).
        let sorted = fetched.sorted { $0.bedtime < $1.bedtime }
        dataPoints = sorted.map { entry in
            DataPoint(
                id: entry.id,
                date: entry.bedtime,
                durationHours: entry.sleepDurationSeconds / 3600,
                effectiveDurationHours: entry.effectiveSleepSeconds / 3600,
                wakeUpsCount: entry.wakeUps.count
            )
        }

        let maxCount = dataPoints.map(\.wakeUpsCount).max() ?? 0
        maxWakeUpsRelative = max(1, maxCount) // floor 1 — évite divide-by-zero scaling
    }
}
