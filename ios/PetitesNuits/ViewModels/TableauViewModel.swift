import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Tableau". Liste chronologique inversée des nuits,
/// support swipe-to-delete. Observe `NightNotifications` pour se rafraîchir
/// quand une nuit est ajoutée / modifiée / supprimée depuis un autre onglet.
@MainActor
@Observable
final class TableauViewModel {
    private let modelContext: ModelContext
    private let notificationCenter: NotificationCenter
    private(set) var entries: [NightEntry] = []

    init(modelContext: ModelContext, notificationCenter: NotificationCenter = .default) {
        self.modelContext = modelContext
        self.notificationCenter = notificationCenter
    }

    func refresh() {
        let descriptor = FetchDescriptor<NightEntry>(
            sortBy: [SortDescriptor(\.bedtime, order: .reverse)]
        )
        entries = (try? modelContext.fetch(descriptor)) ?? []
    }

    func delete(entry: NightEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
        refresh()
        notificationCenter.post(name: NightNotifications.deleted, object: nil)
    }

    /// Observe les notifications de cycle de vie d'une `NightEntry` et
    /// rafraîchit la liste à chaque émission. À appeler depuis `.task {}` —
    /// se termine quand la `Task` est annulée.
    func observeNightChanges() async {
        for await _ in NightNotifications.merged(on: notificationCenter) {
            if Task.isCancelled { return }
            refresh()
        }
    }
}
