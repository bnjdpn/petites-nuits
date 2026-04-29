import Foundation
import SwiftData

/// Seed le `ModelContainer` in-memory avec un jeu de nuits réaliste pour les
/// captures fastlane. Activé via le launch argument `-screenshot` côté
/// `PetitesNuitsApp`. Les nuits couvrent 2 semaines, incluent une mauvaise
/// nuit (mood `.bad`) et une excellente (mood `.great`) pour démontrer la
/// palette heatmap du calendrier.
@MainActor
enum ScreenshotDataService {
    /// Insère un jeu de 7 nuits réalistes dans le `modelContext` fourni.
    /// Idempotent : si le store contient déjà des entrées, ne fait rien.
    static func seedIfNeeded(modelContext: ModelContext, now: Date = .now) {
        let descriptor = FetchDescriptor<NightEntry>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let calendar = Calendar(identifier: .gregorian)
        let entries = makeFixtureEntries(now: now, calendar: calendar)
        for entry in entries {
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    /// Fixture publique pour permettre des tests unitaires de la fonction.
    static func makeFixtureEntries(now: Date, calendar: Calendar = .init(identifier: .gregorian)) -> [NightEntry] {
        // Jeu de 7 nuits : 1 super, 1 terrible, 5 normales avec variations.
        // Couvre les 14 derniers jours pour aussi alimenter le graphique.
        let dayOffsets: [Int] = [-13, -10, -7, -5, -3, -2, -1]
        let bedHours = [21, 22, 23, 22, 22, 21, 22]
        let bedMinutes = [30, 0, 15, 45, 30, 0, 15]
        let durationsHours: [Double] = [9.5, 7.0, 8.5, 6.5, 9.0, 7.5, 10.0]
        let moods: [Mood] = [.great, .bad, .good, .terrible, .great, .ok, .great]
        let wakeUpsCounts = [0, 3, 1, 4, 0, 2, 0]
        let feedingsCounts = [0, 2, 1, 3, 0, 1, 0]
        let notes = [
            "Première bonne nuit de la semaine.",
            "Beaucoup de réveils, dents.",
            "Un réveil tétée vers 3h.",
            "Nuit difficile, fièvre.",
            "Endormi seul, calme total.",
            "Réveil de 4h, rendormi vite.",
            ""
        ]

        var results: [NightEntry] = []
        for index in 0..<dayOffsets.count {
            guard let bedDate = calendar.date(byAdding: DateComponents(day: dayOffsets[index]), to: now) else { continue }
            var bedComponents = calendar.dateComponents([.year, .month, .day], from: bedDate)
            bedComponents.hour = bedHours[index]
            bedComponents.minute = bedMinutes[index]
            guard let bedtime = calendar.date(from: bedComponents) else { continue }
            let wakeUpTime = bedtime.addingTimeInterval(durationsHours[index] * 3600)

            var wakeUps: [WakeUp] = []
            for wakeIndex in 0..<wakeUpsCounts[index] {
                let offsetSeconds = Double(wakeIndex + 1) * (durationsHours[index] * 3600 / Double(wakeUpsCounts[index] + 1))
                let isFeeding = wakeIndex < feedingsCounts[index]
                wakeUps.append(WakeUp(
                    time: bedtime.addingTimeInterval(offsetSeconds),
                    durationMinutes: isFeeding ? 20 : 8,
                    isFeeding: isFeeding,
                    note: ""
                ))
            }

            results.append(NightEntry(
                bedtime: bedtime,
                wakeUpTime: wakeUpTime,
                wakeUps: wakeUps,
                mood: moods[index],
                notes: notes[index]
            ))
        }
        return results
    }
}
