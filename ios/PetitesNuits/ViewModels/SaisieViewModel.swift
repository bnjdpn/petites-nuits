import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Saisie". Deux modes :
/// - **création** : `init(modelContext:)` — saisie d'une nouvelle nuit.
/// - **édition** : `init(modelContext:editing:)` — pré-rempli avec une nuit
///   existante. `save()` met à jour, `deleteEditedEntry()` supprime.
///
/// Garantit que `wakeUpTime > bedtime` en roulant la date au lendemain si
/// nécessaire (risk #1 spec §2.1).
///
/// Après chaque `save()` ou `deleteEditedEntry()`, une notification
/// `NightNotifications.saved` ou `.deleted` est postée pour que les autres
/// onglets (calendrier, graphique, tableau, stats) puissent rafraîchir.
@MainActor
@Observable
final class SaisieViewModel {
    enum EditError: Error, Equatable {
        case notInEditMode
    }

    private let modelContext: ModelContext
    private let calendar: Calendar
    private let notificationCenter: NotificationCenter
    private let editingEntry: NightEntry?

    var bedtime: Date
    var wakeUpTime: Date
    var mood: Mood = .ok
    var wakeUps: [WakeUp] = []
    var notes: String = ""

    var isEditing: Bool { editingEntry != nil }

    init(
        modelContext: ModelContext,
        editing: NightEntry? = nil,
        calendar: Calendar = .autoupdatingCurrent,
        now: Date = .now,
        notificationCenter: NotificationCenter = .default
    ) {
        self.modelContext = modelContext
        self.calendar = calendar
        self.notificationCenter = notificationCenter
        self.editingEntry = editing

        if let editing {
            self.bedtime = editing.bedtime
            self.wakeUpTime = editing.wakeUpTime
            self.mood = editing.mood
            self.wakeUps = editing.wakeUps
            self.notes = editing.notes
        } else {
            // Defaults : coucher 22h aujourd'hui, réveil 7h demain.
            let startOfDay = calendar.startOfDay(for: now)
            self.bedtime = calendar.date(byAdding: .hour, value: 22, to: startOfDay) ?? now
            self.wakeUpTime = calendar.date(byAdding: .hour, value: 31, to: startOfDay) ?? now
        }
    }

    // MARK: - WakeUps

    func addWakeUp(at time: Date, durationMinutes: Int, isFeeding: Bool, note: String = "") {
        wakeUps.append(WakeUp(
            time: time,
            durationMinutes: durationMinutes,
            isFeeding: isFeeding,
            note: note
        ))
    }

    func removeWakeUp(id: UUID) {
        wakeUps.removeAll { $0.id == id }
    }

    // MARK: - Cross-midnight handling (risk #1)

    /// Quand l'utilisateur sélectionne une heure de réveil dans un picker
    /// "même jour", on roule au lendemain si `wakeRaw <= bedtime`.
    func setWakeUpTimeRolling(toSameDayValue wakeRaw: Date) {
        if wakeRaw > bedtime {
            wakeUpTime = wakeRaw
            return
        }
        // Roll +1 day
        if let rolled = calendar.date(byAdding: .day, value: 1, to: wakeRaw) {
            wakeUpTime = rolled
        } else {
            wakeUpTime = wakeRaw
        }
    }

    var computedDurationSeconds: TimeInterval {
        max(0, wakeUpTime.timeIntervalSince(bedtime))
    }

    // MARK: - Persistence

    func save() throws {
        if let editingEntry {
            // Update path — mute existing entry in place to preserve identity.
            editingEntry.bedtime = bedtime
            editingEntry.wakeUpTime = wakeUpTime
            editingEntry.wakeUps = wakeUps
            editingEntry.mood = mood
            editingEntry.notes = notes
            try modelContext.save()
        } else {
            let entry = NightEntry(
                bedtime: bedtime,
                wakeUpTime: wakeUpTime,
                wakeUps: wakeUps,
                mood: mood,
                notes: notes
            )
            modelContext.insert(entry)
            try modelContext.save()
            reset()
        }
        notificationCenter.post(name: NightNotifications.saved, object: nil)
    }

    func deleteEditedEntry() throws {
        guard let editingEntry else {
            throw EditError.notInEditMode
        }
        modelContext.delete(editingEntry)
        try modelContext.save()
        notificationCenter.post(name: NightNotifications.deleted, object: nil)
    }

    func reset() {
        mood = .ok
        wakeUps = []
        notes = ""
    }
}
