import SwiftData
import SwiftUI

/// Onglet "Calendrier" — grille mensuelle lundi-first FR avec heatmap.
struct CalendrierView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CalendrierViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.veloursProfond.ignoresSafeArea()
                if let viewModel {
                    content(viewModel: viewModel)
                }
            }
            .navigationTitle("Calendrier")
            .toolbarBackground(Theme.veloursProfond, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if viewModel == nil {
                let newViewModel = CalendrierViewModel(modelContext: modelContext)
                newViewModel.refresh()
                viewModel = newViewModel
            } else {
                viewModel?.refresh()
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: CalendrierViewModel) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            header(viewModel: viewModel)
            CalendarGrid(
                daysInMonth: viewModel.daysInMonth,
                firstDayOffset: viewModel.firstDayOffsetMondayFirst,
                entryForDay: { viewModel.entry(forDay: $0) }
            )
            Spacer()
        }
        .padding(Theme.Spacing.md)
    }

    private func header(viewModel: CalendrierViewModel) -> some View {
        HStack {
            Button {
                viewModel.previousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Theme.lumiereIvoire)
            }
            .accessibilityLabel(Text("Mois précédent"))
            Spacer()
            Text(monthLabel(viewModel.selectedMonth))
                .font(Theme.headline(.title2))
                .foregroundStyle(Theme.lumiereIvoire)
            Spacer()
            Button {
                viewModel.nextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.lumiereIvoire)
            }
            .accessibilityLabel(Text("Mois suivant"))
        }
    }

    private func monthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
}
