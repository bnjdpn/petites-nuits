import SwiftUI

/// Placeholder Phase 1 — les écrans définitifs (TabView 5 onglets) seront
/// implémentés en Phase 2 après bootstrap design Stitch.
struct ContentView: View {
    var body: some View {
        ZStack {
            Theme.deepNavy.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("\u{1F319}")
                    .font(.system(size: 64))
                Text("Petites Nuits")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Theme.starGold)
                Text("Phase 1 — port en cours")
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
