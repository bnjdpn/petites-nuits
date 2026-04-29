import Foundation

/// Réveil nocturne. Type valeur sérialisé en JSON dans la colonne `wakeUps`
/// du `NightEntry` SwiftData (mêmes champs que la `data class WakeUp` Room
/// Android). `Sendable` pour traverser les boundaries d'actor.
struct WakeUp: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var time: Date
    var durationMinutes: Int
    var isFeeding: Bool
    var note: String

    init(
        id: UUID = UUID(),
        time: Date,
        durationMinutes: Int,
        isFeeding: Bool,
        note: String = ""
    ) {
        self.id = id
        self.time = time
        self.durationMinutes = durationMinutes
        self.isFeeding = isFeeding
        self.note = note
    }
}
