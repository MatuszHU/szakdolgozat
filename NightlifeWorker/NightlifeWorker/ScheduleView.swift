import SwiftUI
import SharedKit

@K5
struct ScheduleView: View {
    @Environment(\.locale) private var locale
    @ObservedObject var viewModel: ScheduleViewModel

    var body: some View {
        Group {
            if viewModel.hasNoUpcomingShifts && viewModel.schedule.past.isEmpty {
                ContentUnavailableView("Nincs beosztásod",
                                       systemImage: "calendar",
                                       description: Text("A műszakjaidat az adminisztrátor osztja be."))
            } else {
                List {
                    if let current = viewModel.schedule.current {
                        Section("Most") {
                            ShiftRow(entry: current, showsDay: false)
                        }
                    }
                    if viewModel.hasNoUpcomingShifts {
                        Section {
                            Text("Nincs következő műszakod.").foregroundStyle(.secondary)
                        }
                    }
                    ForEach(viewModel.days) { day in
                        let entries = day.entries.filter { $0.status == .upcoming }
                        if !entries.isEmpty {
                            Section(day.date.formatted(.dateTime.month(.wide).day().weekday(.wide).locale(locale))) {
                                ForEach(entries) { ShiftRow(entry: $0, showsDay: false) }
                            }
                        }
                    }
                    if !viewModel.schedule.past.isEmpty {
                        Section("Korábbi műszakok") {
                            ForEach(viewModel.schedule.past) { ShiftRow(entry: $0, showsDay: true) }
                        }
                    }
                }
                .refreshable { viewModel.refresh() }
            }
        }
        .navigationTitle("Beosztás")
        .onAppear { viewModel.refresh() }
    }
}

@K5
private struct ShiftRow: View {
    @Environment(\.locale) private var locale
    let entry: WorkerSchedule.Entry
    let showsDay: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(time).font(.headline)
                Spacer()
                if entry.status == .current {
                    Text("Folyamatban").font(.caption.bold()).foregroundStyle(.green)
                }
            }
            Label {
                if let place = entry.place {
                    Text(verbatim: place)
                } else {
                    Text("Nincs megadott zóna")
                }
            } icon: {
                Image(systemName: "mappin.and.ellipse")
            }
                .foregroundStyle(entry.place == nil ? .secondary : .primary)
            if !entry.tasks.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(entry.tasks) { task in
                        Label(task.title, systemImage: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .foregroundStyle(entry.status == .past ? .secondary : .primary)
    }

    private var time: String {
        let start = entry.shift.startTime
        let range = start.formatted(Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)) + "–"
            + entry.shift.endTime.formatted(Date.FormatStyle(date: .omitted, time: .shortened).locale(locale))
        return showsDay ? start.formatted(.dateTime.month(.abbreviated).day().locale(locale)) + " " + range : range
    }
}
