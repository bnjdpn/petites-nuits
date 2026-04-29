import SwiftUI

/// Racine de l'app — TabView 5 onglets (Saisie, Calendrier, Graphique,
/// Tableau, Stats). Chaque vue gère son propre ViewModel.
struct ContentView: View {
    @State private var selectedTab: Tab = .saisie

    enum Tab: Hashable {
        case saisie
        case calendrier
        case graphique
        case tableau
        case stats
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SaisieView()
                .tabItem {
                    Label("Saisie", systemImage: "moon.stars")
                }
                .tag(Tab.saisie)

            CalendrierView()
                .tabItem {
                    Label("Calendrier", systemImage: "calendar")
                }
                .tag(Tab.calendrier)

            GraphiqueView()
                .tabItem {
                    Label("Graphique", systemImage: "chart.bar")
                }
                .tag(Tab.graphique)

            TableauView()
                .tabItem {
                    Label("Tableau", systemImage: "list.bullet")
                }
                .tag(Tab.tableau)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.pie")
                }
                .tag(Tab.stats)
        }
        .tint(Theme.etoileOr)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NightEntry.self, inMemory: true)
}
