import SwiftUI

/// Capsule color-coded selon `Mood`. Tap optionnel pour sélection.
struct MoodChip: View {
    let mood: Mood
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        let label = Text(mood.displayName)
            .font(Theme.body(.subheadline).weight(.medium))
            .foregroundStyle(isSelected ? Theme.veloursProfond : Theme.lumiereIvoire)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? mood.color : Theme.bleuLune)
            )
            .overlay(
                Capsule()
                    .strokeBorder(mood.color.opacity(isSelected ? 0 : 0.6), lineWidth: 1)
            )
            .accessibilityLabel(Text("Humeur \(mood.displayName)"))
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])

        if let onTap {
            Button(action: onTap) { label }
                .buttonStyle(.plain)
        } else {
            label
        }
    }
}

#Preview {
    HStack {
        ForEach(Mood.allCases) { mood in
            MoodChip(mood: mood, isSelected: mood == .good)
        }
    }
    .padding()
    .background(Theme.veloursProfond)
}
