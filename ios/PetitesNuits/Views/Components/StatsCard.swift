import SwiftUI

/// Card stat : hero number serif + label inter.
struct StatsCard: View {
    let title: String
    let value: String
    var subtitle: String?
    var accent: Color = Theme.indigoNuit

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.body(.caption).weight(.medium))
                .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
                .textCase(.uppercase)
            Text(value)
                .font(Theme.headline(.largeTitle))
                .foregroundStyle(accent)
                .monospacedDigit()
            if let subtitle {
                Text(subtitle)
                    .font(Theme.body(.caption))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(Theme.bleuLune)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title) : \(value)\(subtitle.map { ", \($0)" } ?? "")"))
    }
}
