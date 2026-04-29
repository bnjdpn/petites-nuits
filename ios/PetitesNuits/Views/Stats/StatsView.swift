import SwiftData
import SwiftUI

/// Onglet "Stats" — 3 StatsCards (avg durée 30j, avg réveils, tendance).
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StatsViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.veloursProfond.ignoresSafeArea()
                if let viewModel {
                    content(viewModel: viewModel)
                }
            }
            .navigationTitle("Statistiques")
            .toolbarBackground(Theme.veloursProfond, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if viewModel == nil {
                let newViewModel = StatsViewModel(modelContext: modelContext)
                newViewModel.refresh()
                viewModel = newViewModel
            } else {
                viewModel?.refresh()
            }
            await viewModel?.observeNightChanges()
        }
    }

    @ViewBuilder
    private func content(viewModel: StatsViewModel) -> some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                StatsCard(
                    title: "Durée moyenne",
                    value: formatDuration(viewModel.averageDurationSeconds),
                    subtitle: "Sur \(viewModel.totalNights) nuit\(viewModel.totalNights > 1 ? "s" : "")",
                    accent: Theme.indigoNuit
                )
                StatsCard(
                    title: "Réveils en moyenne",
                    value: formatAverage(viewModel.averageWakeUpsPerNight),
                    subtitle: "par nuit",
                    accent: Theme.etoileOr
                )
                StatsCard(
                    title: "Tendance",
                    value: trendLabel(viewModel.trend),
                    subtitle: "7 derniers jours vs précédents",
                    accent: trendColor(viewModel.trend)
                )
            }
            .padding(Theme.Spacing.md)
        }
    }

    private func formatDuration(_ seconds: TimeInterval?) -> String {
        guard let seconds else { return "—" }
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h\(String(format: "%02d", minutes))"
    }

    private func formatAverage(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.1f", value)
    }

    private func trendLabel(_ trend: StatsViewModel.Trend) -> String {
        switch trend {
        case .improving: "En amélioration"
        case .declining: "En baisse"
        case .stable: "Stable"
        }
    }

    private func trendColor(_ trend: StatsViewModel.Trend) -> Color {
        switch trend {
        case .improving: Mood.great.color
        case .declining: Mood.bad.color
        case .stable: Theme.indigoNuit
        }
    }
}
