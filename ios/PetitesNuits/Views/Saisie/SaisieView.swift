import SwiftData
import SwiftUI

/// Onglet "Saisie" — formulaire d'ajout d'une nuit.
struct SaisieView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: SaisieViewModel?
    @State private var showingWakeUpSheet = false
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.veloursProfond.ignoresSafeArea()
                if let viewModel {
                    formContent(viewModel: viewModel)
                }
            }
            .navigationTitle("Nouvelle nuit")
            .toolbarBackground(Theme.veloursProfond, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            if viewModel == nil {
                viewModel = SaisieViewModel(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    private func formContent(viewModel: SaisieViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                timeSection(viewModel: viewModel)
                moodSection(viewModel: viewModel)
                wakeUpsSection(viewModel: viewModel)
                notesSection(viewModel: viewModel)
                saveButton(viewModel: viewModel)
            }
            .padding(Theme.Spacing.md)
        }
        .sheet(isPresented: $showingWakeUpSheet) {
            AddWakeUpSheet { time, duration, isFeeding in
                viewModel.addWakeUp(at: time, durationMinutes: duration, isFeeding: isFeeding)
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError ?? "")
        }
    }

    @ViewBuilder
    private func timeSection(viewModel: SaisieViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Coucher et réveil")
                .font(Theme.headline(.title3))
                .foregroundStyle(Theme.lumiereIvoire)

            VStack(spacing: Theme.Spacing.sm) {
                DatePicker(
                    "Coucher",
                    selection: Binding(
                        get: { viewModel.bedtime },
                        set: { viewModel.bedtime = $0 }
                    )
                )
                .datePickerStyle(.compact)
                .accessibilityLabel(Text("Heure du coucher"))

                DatePicker(
                    "Réveil",
                    selection: Binding(
                        get: { viewModel.wakeUpTime },
                        set: { viewModel.wakeUpTime = $0 }
                    )
                )
                .datePickerStyle(.compact)
                .accessibilityLabel(Text("Heure du réveil"))
            }
            .foregroundStyle(Theme.lumiereIvoire)
            .padding(Theme.Spacing.md)
            .background(Theme.bleuLune)
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))

            Text("Durée : \(durationLabel(seconds: viewModel.computedDurationSeconds))")
                .font(Theme.numerics(.callout))
                .foregroundStyle(Theme.indigoNuit)
        }
    }

    @ViewBuilder
    private func moodSection(viewModel: SaisieViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Humeur au réveil")
                .font(Theme.headline(.title3))
                .foregroundStyle(Theme.lumiereIvoire)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(Mood.allCases) { mood in
                        MoodChip(mood: mood, isSelected: viewModel.mood == mood) {
                            viewModel.mood = mood
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func wakeUpsSection(viewModel: SaisieViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Réveils nocturnes")
                    .font(Theme.headline(.title3))
                    .foregroundStyle(Theme.lumiereIvoire)
                Spacer()
                Button {
                    showingWakeUpSheet = true
                } label: {
                    Label("Ajouter", systemImage: "plus.circle.fill")
                        .foregroundStyle(Theme.etoileOr)
                }
                .accessibilityLabel(Text("Ajouter un réveil"))
            }

            if viewModel.wakeUps.isEmpty {
                Text("Aucun réveil")
                    .font(Theme.body(.subheadline))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.6))
            } else {
                ForEach(viewModel.wakeUps) { wakeUp in
                    wakeUpRow(wakeUp: wakeUp, viewModel: viewModel)
                }
            }
        }
    }

    private func wakeUpRow(wakeUp: WakeUp, viewModel: SaisieViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatHour(wakeUp.time))
                    .font(Theme.numerics(.subheadline))
                    .foregroundStyle(Theme.lumiereIvoire)
                Text("\(wakeUp.durationMinutes) min\(wakeUp.isFeeding ? " · tétée" : "")")
                    .font(Theme.body(.caption))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }
            Spacer()
            Button {
                viewModel.removeWakeUp(id: wakeUp.id)
            } label: {
                Image(systemName: "minus.circle")
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }
            .accessibilityLabel(Text("Supprimer ce réveil"))
        }
        .padding(Theme.Spacing.sm)
        .background(Theme.bleuLune)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }

    @ViewBuilder
    private func notesSection(viewModel: SaisieViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Notes")
                .font(Theme.headline(.title3))
                .foregroundStyle(Theme.lumiereIvoire)
            TextField(
                "Optionnel",
                text: Binding(get: { viewModel.notes }, set: { viewModel.notes = $0 }),
                axis: .vertical
            )
            .lineLimit(3...6)
            .padding(Theme.Spacing.sm)
            .background(Theme.bleuLune)
            .foregroundStyle(Theme.lumiereIvoire)
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            .accessibilityLabel(Text("Notes libres"))
        }
    }

    @ViewBuilder
    private func saveButton(viewModel: SaisieViewModel) -> some View {
        Button {
            do {
                try viewModel.save()
            } catch {
                saveError = error.localizedDescription
            }
        } label: {
            Text("Enregistrer")
                .font(Theme.body(.headline).weight(.semibold))
                .foregroundStyle(Theme.veloursProfond)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(Theme.etoileOr)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        }
        .accessibilityLabel(Text("Enregistrer la nuit"))
    }

    private func durationLabel(seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h\(String(format: "%02d", minutes))"
    }

    private func formatHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH'h'mm"
        return formatter.string(from: date)
    }
}

// MARK: - AddWakeUpSheet

private struct AddWakeUpSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var time = Date()
    @State private var durationMinutes = 10
    @State private var isFeeding = false
    let onAdd: (Date, Int, Bool) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.veloursProfond.ignoresSafeArea()
                Form {
                    Section {
                        DatePicker("Heure", selection: $time, displayedComponents: .hourAndMinute)
                        Stepper("Durée : \(durationMinutes) min", value: $durationMinutes, in: 1...120, step: 5)
                        Toggle("Tétée / biberon", isOn: $isFeeding)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Réveil nocturne")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        onAdd(time, durationMinutes, isFeeding)
                        dismiss()
                    }
                }
            }
        }
    }
}
