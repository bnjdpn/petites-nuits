import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Tableau". Liste chronologique inversée des nuits,
/// support swipe-to-delete.
@MainActor
@Observable
final class TableauViewModel {
    private let modelContext: ModelContext
    private(set) var entries: [NightEntry] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
    }
}
