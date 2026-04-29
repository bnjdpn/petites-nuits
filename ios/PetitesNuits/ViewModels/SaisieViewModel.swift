import Foundation
import Observation
import SwiftData

/// ViewModel de l'onglet "Saisie". Gère l'ajout d'une nuit (bedtime,
/// wakeUpTime, mood, wakeUps, notes). Garantit que `wakeUpTime > bedtime`
/// en roulant la date au lendemain si nécessaire (risk #1 spec §2.1).
@MainActor
@Observable
final class SaisieViewModel {
    private let modelContext: ModelContext
    private let calendar: Calendar

    var bedtime: Date
    var wakeUpTime: Date
    var mood: Mood = .ok
    var wakeUps: [WakeUp] = []
    var notes: String = ""

    init(modelContext: ModelContext, calendar: Calendar = .autoupdatingCurrent, now: Date = .now) {
        self.modelContext = modelContext
        self.calendar = calendar
        // Defaults : coucher 22h aujourd'hui, réveil 7h demain.
        let startOfDay = calendar.startOfDay(for: now)
        self.bedtime = calendar.date(byAdding: .hour, value: 22, to: startOfDay) ?? now
        self.wakeUpTime = calendar.date(byAdding: .hour, value: 31, to: startOfDay) ?? now
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

    func reset() {
        mood = .ok
        wakeUps = []
        notes = ""
    }
}
