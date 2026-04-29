import Foundation
import SwiftData

/// Une nuit de sommeil enregistrée. Mirroir de l'entité Room Android
/// `NightEntry`. Le tableau `wakeUps` est stocké en JSON natif par SwiftData.
@Model
final class NightEntry {
    var id: UUID = UUID()
    var bedtime: Date = Date()
    var wakeUpTime: Date = Date()
    var wakeUps: [WakeUp] = []
    var moodRawValue: String = Mood.ok.rawValue
    var notes: String = ""

    init(
        id: UUID = UUID(),
        bedtime: Date,
        wakeUpTime: Date,
        wakeUps: [WakeUp] = [],
        mood: Mood = .ok,
        notes: String = ""
    ) {
        self.id = id
        self.bedtime = bedtime
        self.wakeUpTime = wakeUpTime
        self.wakeUps = wakeUps
        self.moodRawValue = mood.rawValue
        self.notes = notes
    }

    var mood: Mood {
        get { Mood(rawValue: moodRawValue) ?? .ok }
        set { moodRawValue = newValue.rawValue }
    }

    // MARK: - Computed properties

    /// Durée brute coucher → réveil (peut traverser minuit ; le ViewModel
    /// d'édition garantit que `wakeUpTime > bedtime` en ajoutant +1 jour
    /// si nécessaire — cf. spec §2.1 cross-midnight).
    var sleepDurationSeconds: TimeInterval {
        wakeUpTime.timeIntervalSince(bedtime)
    }

    /// Sommeil net (durée brute moins temps cumulé des réveils).
    /// Borné à zéro pour ne jamais devenir négatif.
    var effectiveSleepSeconds: TimeInterval {
        max(0, sleepDurationSeconds - totalWakeUpSeconds)
    }

    /// Nombre de réveils marqués comme tétée/biberon.
    var feedingCount: Int {
        wakeUps.reduce(0) { $0 + ($1.isFeeding ? 1 : 0) }
    }

    /// Temps cumulé passé éveillé pendant la nuit (en secondes).
    var totalWakeUpSeconds: TimeInterval {
        TimeInterval(wakeUps.reduce(0) { $0 + $1.durationMinutes }) * 60
    }

    // MARK: - Formatting

    func formatDuration() -> String {
        Self.formatHoursMinutes(seconds: sleepDurationSeconds)
    }

    func formatEffectiveDuration() -> String {
        Self.formatHoursMinutes(seconds: effectiveSleepSeconds)
    }

    private static func formatHoursMinutes(seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h\(String(format: "%02d", minutes))"
    }
}
