import SwiftUI
import SharedKit

@K12
struct WorkSummaryView: View {
    @Environment(\.locale) private var locale
    @ObservedObject var viewModel: WorkSummaryViewModel

    var body: some View {
        List {
            Section {
                hoursRow(title: "Ebben az időszakban", hours: viewModel.summary.hoursThisPeriod,
                         period: viewModel.summary.currentPeriod)
                hoursRow(title: "Előző időszak", hours: viewModel.summary.hoursPreviousPeriod,
                         period: viewModel.summary.previousPeriod)
                LabeledContent { Text(hoursText(viewModel.summary.totalHours)) } label: { Text("Összesen") }
            } header: {
                Text("Ledolgozott órák")
            } footer: {
                Text("Műszakok ebben az időszakban: \(viewModel.summary.shiftsThisPeriod)")
            }
            Section("Korábbi feladatok") {
                if viewModel.summary.pastTasks.isEmpty {
                    Text("Még nincs lezárult feladatod.").foregroundStyle(.secondary)
                }
                ForEach(viewModel.summary.pastTasks) { past in
                    HStack {
                        Image(systemName: past.task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(past.task.isCompleted ? .green : .secondary)
                        Text(past.task.title)
                        Spacer()
                        Text(past.shiftStart.formatted(.dateTime.month(.abbreviated).day().locale(locale)))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Összesítés")
        .onAppear { viewModel.refresh() }
        .refreshable { viewModel.refresh() }
    }

    private func hoursRow(title: LocalizedStringKey, hours: Double, period: DateInterval) -> some View {
        LabeledContent {
            Text(hoursText(hours))
        } label: {
            Text(title)
            Text(period.start.formatted(.dateTime.month(.abbreviated).day().locale(locale)) + " – "
                 + period.end.addingTimeInterval(-1).formatted(.dateTime.month(.abbreviated).day().locale(locale)))
        }
    }

    private func hoursText(_ value: Double) -> LocalizedStringResource {
        "\(value.formatted(.number.precision(.fractionLength(0...1)).locale(locale))) óra"
    }
}
