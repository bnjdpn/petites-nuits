import SwiftData
import SwiftUI

/// Onglet "Graphique" — Swift Charts dual-axis sur 14 dernières nuits.
struct GraphiqueView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GraphiqueViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.veloursProfond.ignoresSafeArea()
                if let viewModel {
                    content(viewModel: viewModel)
                }
            }
            .navigationTitle("Évolution")
            .toolbarBackground(Theme.veloursProfond, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if viewModel == nil {
                let newViewModel = GraphiqueViewModel(modelContext: modelContext)
                newViewModel.refresh()
                viewModel = newViewModel
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: GraphiqueViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("14 dernières nuits")
                    .font(Theme.headline(.title3))
                    .foregroundStyle(Theme.lumiereIvoire)
                DurationChart(
                    dataPoints: viewModel.dataPoints,
                    maxWakeUps: viewModel.maxWakeUpsRelative
                )
                legend
            }
            .padding(Theme.Spacing.md)
        }
    }

    private var legend: some View {
        HStack(spacing: Theme.Spacing.lg) {
            HStack(spacing: Theme.Spacing.xs) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.indigoNuit)
                    .frame(width: 14, height: 10)
                Text("Durée")
                    .font(Theme.body(.caption))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }
            HStack(spacing: Theme.Spacing.xs) {
                Circle()
                    .fill(Theme.etoileOr)
                    .frame(width: 8, height: 8)
                Text("Réveils")
                    .font(Theme.body(.caption))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }
            Spacer()
        }
    }
}
