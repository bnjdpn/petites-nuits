import SwiftUI

/// Row d'entrée nuit : date + heure couché + durée + humeur + étoiles
/// réveils. Conforme `petites-nuits/design/system.md`.
struct NightEntryRow: View {
    let entry: NightEntry

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEE d MMM"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH'h'mm"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(Self.dateFormatter.string(from: entry.bedtime))
                    .font(Theme.body(.subheadline).weight(.semibold))
                    .foregroundStyle(Theme.lumiereIvoire)
                let bed = Self.timeFormatter.string(from: entry.bedtime)
                let wake = Self.timeFormatter.string(from: entry.wakeUpTime)
                Text("\(bed) → \(wake)")
                    .font(Theme.numerics(.caption))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                Text(entry.formatDuration())
                    .font(Theme.headline(.title3))
                    .foregroundStyle(Theme.indigoNuit)
                WakeUpStars(count: entry.wakeUps.count)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.bleuLune)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: Text {
        let date = Self.dateFormatter.string(from: entry.bedtime)
        let bed = Self.timeFormatter.string(from: entry.bedtime)
        let wake = Self.timeFormatter.string(from: entry.wakeUpTime)
        let duration = entry.formatDuration()
        let wakeCount = entry.wakeUps.count
        let moodName = entry.mood.displayName
        return Text(
            "Nuit du \(date), couché \(bed), réveil \(wake), "
            + "durée \(duration), \(wakeCount) réveils, ressenti \(moodName)"
        )
    }
}
