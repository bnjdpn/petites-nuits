import SwiftData
import SwiftUI

/// Onglet "Tableau" — liste chronologique inversée des nuits.
struct TableauView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TableauViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.veloursProfond.ignoresSafeArea()
                if let viewModel {
                    content(viewModel: viewModel)
                }
            }
            .navigationTitle("Historique")
            .toolbarBackground(Theme.veloursProfond, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if viewModel == nil {
                let newViewModel = TableauViewModel(modelContext: modelContext)
                newViewModel.refresh()
                viewModel = newViewModel
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: TableauViewModel) -> some View {
        if viewModel.entries.isEmpty {
            VStack(spacing: Theme.Spacing.md) {
                Text("Aucune nuit enregistrée")
                    .font(Theme.headline(.title3))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
                Text("Commencez par saisir votre première nuit dans l'onglet Saisie.")
                    .font(Theme.body(.subheadline))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(Theme.Spacing.lg)
        } else {
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.sm) {
                    ForEach(viewModel.entries) { entry in
                        NightEntryRow(entry: entry)
                            .swipeActions {
                                Button(role: .destructive) {
                                    try? viewModel.delete(entry: entry)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(Theme.Spacing.md)
            }
        }
    }
}
