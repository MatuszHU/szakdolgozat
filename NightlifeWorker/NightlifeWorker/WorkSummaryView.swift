import SwiftUI
import SharedKit

@K12
struct WorkSummaryView: View {
    @ObservedObject var viewModel: WorkSummaryViewModel

    var body: some View {
        List {
            Section {
                hoursRow(title: "Ebben az időszakban", hours: viewModel.summary.hoursThisPeriod,
                         period: viewModel.summary.currentPeriod)
                hoursRow(title: "Előző időszak", hours: viewModel.summary.hoursPreviousPeriod,
                         period: viewModel.summary.previousPeriod)
                LabeledContent("Összesen", value: Self.hours(viewModel.summary.totalHours))
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
                        Text(past.shiftStart.formatted(.dateTime.month(.abbreviated).day()))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Összesítés")
        .onAppear { viewModel.refresh() }
        .refreshable { viewModel.refresh() }
    }

    private func hoursRow(title: String, hours: Double, period: DateInterval) -> some View {
        LabeledContent {
            Text(Self.hours(hours))
        } label: {
            Text(title)
            Text(period.start.formatted(.dateTime.month(.abbreviated).day()) + " – "
                 + period.end.addingTimeInterval(-1).formatted(.dateTime.month(.abbreviated).day()))
        }
    }

    private static func hours(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1))) + " óra"
    }
}
