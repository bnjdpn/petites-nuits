import SwiftUI

/// HStack de Circle 6pt en `etoileOr`. Jusqu'à 5 étoiles affichées ;
/// au-delà, on montre "5+ N" pour densité visuelle.
struct WakeUpStars: View {
    let count: Int
    private let maxDisplayed = 5

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            let displayed = min(count, maxDisplayed)
            ForEach(0..<displayed, id: \.self) { _ in
                Circle()
                    .fill(Theme.etoileOr)
                    .frame(width: 6, height: 6)
            }
            if count > maxDisplayed {
                Text("+\(count - maxDisplayed)")
                    .font(Theme.numerics(.caption))
                    .foregroundStyle(Theme.etoileOr)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(count) réveils"))
    }
}

#Preview {
    VStack {
        WakeUpStars(count: 0)
        WakeUpStars(count: 3)
        WakeUpStars(count: 7)
    }
    .padding()
    .background(Theme.veloursProfond)
}
