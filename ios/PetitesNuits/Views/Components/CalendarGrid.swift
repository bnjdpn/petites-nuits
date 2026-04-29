import SwiftUI

/// Grille mensuelle lundi-first FR. Heatmap qualité selon mood.
struct CalendarGrid: View {
    let daysInMonth: Int
    let firstDayOffset: Int
    let entryForDay: (Int) -> NightEntry?
    var onEntryTapped: ((NightEntry) -> Void)?

    private static let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: Theme.Spacing.xs),
        count: 7
    )

    private static let weekdayLabels = ["Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di"]

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Weekday header
            LazyVGrid(columns: Self.columns, spacing: Theme.Spacing.xs) {
                ForEach(Self.weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(Theme.body(.caption).weight(.semibold))
                        .foregroundStyle(Theme.lumiereIvoire.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
            }

            // Grid cells
            LazyVGrid(columns: Self.columns, spacing: Theme.Spacing.xs) {
                ForEach(0..<firstDayOffset, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                ForEach(1...max(daysInMonth, 1), id: \.self) { day in
                    cell(forDay: day)
                }
            }
        }
    }

    @ViewBuilder
    private func cell(forDay day: Int) -> some View {
        let entry = entryForDay(day)
        let fillColor = entry?.mood.color ?? Theme.bleuLune
        Button {
            if let entry, let onEntryTapped {
                onEntryTapped(entry)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(fillColor.opacity(entry == nil ? 0.4 : 0.85))
                Text("\(day)")
                    .font(Theme.numerics(.callout).weight(.medium))
                    .foregroundStyle(entry == nil ? Theme.lumiereIvoire.opacity(0.6) : Theme.veloursProfond)
            }
            .frame(height: 40)
        }
        .buttonStyle(.plain)
        .disabled(entry == nil)
        .accessibilityLabel(accessibilityLabel(day: day, entry: entry))
    }

    private func accessibilityLabel(day: Int, entry: NightEntry?) -> Text {
        if let entry {
            return Text("Jour \(day), nuit enregistrée, ressenti \(entry.mood.displayName)")
        }
        return Text("Jour \(day), aucune nuit")
    }
}
