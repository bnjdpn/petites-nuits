import Charts
import SwiftUI

/// Swift Charts dual-axis : barres durée (BarMark `indigoNuit`) + dots
/// dorés (PointMark `etoileOr`) pour réveils. Axe secondaire échelle
/// relative (risk #4 spec §5).
struct DurationChart: View {
    let dataPoints: [GraphiqueViewModel.DataPoint]
    let maxWakeUps: Int

    var body: some View {
        if dataPoints.isEmpty {
            emptyState
        } else {
            chart
        }
    }

    private var chart: some View {
        let maxHours = max(12, dataPoints.map(\.durationHours).max() ?? 12)
        let scale = maxHours / Double(max(maxWakeUps, 1))

        return Chart {
            ForEach(dataPoints) { point in
                BarMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Durée (h)", point.durationHours)
                )
                .foregroundStyle(Theme.indigoNuit)
                .clipShape(.rect(cornerRadius: 4))

                // PointMark dans la même échelle Y, scaled.
                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Réveils", Double(point.wakeUpsCount) * scale)
                )
                .foregroundStyle(Theme.etoileOr)
                .symbolSize(80)
            }
        }
        .chartYScale(domain: 0...(maxHours + 1))
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(Theme.lumiereIvoire.opacity(0.1))
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { _ in
                AxisValueLabel(format: .dateTime.day().locale(Locale(identifier: "fr_FR")))
                    .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
            }
        }
        .frame(height: 240)
        .padding(Theme.Spacing.md)
        .background(Theme.bleuLune)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }

    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Aucune nuit enregistrée")
                .font(Theme.body(.subheadline))
                .foregroundStyle(Theme.lumiereIvoire.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .background(Theme.bleuLune)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
