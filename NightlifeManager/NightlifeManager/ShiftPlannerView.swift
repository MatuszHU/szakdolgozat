import SwiftUI
import SharedKit

@L3
struct ShiftPlannerView: View {
    @ObservedObject var viewModel: ShiftPlannerViewModel
    let venue: Venue
    @State private var selectedShiftID: UUID?
    @State private var showingNewShift = false
    @State private var showingNewWorker = false
    @State private var newTaskTitle = ""
    @State private var newTaskWorkerID: UUID?

    private var zones: [Zone] { venue.floors.flatMap(\.zones) }
    private var sortedShifts: [Shift] { viewModel.plan.shifts.sorted { $0.startTime < $1.startTime } }
    private var selectedShift: Shift? { viewModel.plan.shifts.first { $0.id == selectedShiftID } }

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $selectedShiftID) {
                Section("Műszakok") {
                    if sortedShifts.isEmpty {
                        Text("Még nincs műszak.").foregroundStyle(.secondary)
                    }
                    ForEach(sortedShifts) { shift in
                        VStack(alignment: .leading) {
                            Text(timeRange(of: shift)).font(.headline)
                            Text("\(zoneName(shift.zoneID)) · \(shift.workerIDs.count)/\(shift.capacity) fő")
                                .foregroundStyle(.secondary)
                        }
                        .tag(shift.id)
                    }
                }
                Section("Munkatársak") {
                    ForEach(viewModel.plan.staff) { worker in
                        LabeledContent(worker.name, value: worker.role.displayName)
                    }
                    Button("Új munkatárs", systemImage: "person.badge.plus") { showingNewWorker = true }
                        .buttonStyle(.borderless)
                }
            }
            .frame(width: 300)
            Divider()
            VStack(alignment: .leading) {
                if let shift = selectedShift {
                    details(of: shift)
                } else {
                    ContentUnavailableView("Válassz egy műszakot", systemImage: "calendar.badge.clock")
                }
                if let message = viewModel.errorMessage {
                    Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red).padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Műszakok")
        .toolbar {
            Button("Új műszak", systemImage: "plus") { showingNewShift = true }
        }
        .sheet(isPresented: $showingNewShift) {
            NewShiftSheet(zones: zones) { start, end, zoneID, capacity in
                selectedShiftID = viewModel.createShift(from: start, to: end, zoneID: zoneID, capacity: capacity)?.id
            }
        }
        .sheet(isPresented: $showingNewWorker) {
            NewWorkerSheet { name, role in viewModel.addWorker(named: name, role: role) }
        }
    }

    private func details(of shift: Shift) -> some View {
        Form {
            Section("Műszak") {
                LabeledContent("Időpont", value: timeRange(of: shift))
                LabeledContent("Zóna", value: zoneName(shift.zoneID))
                LabeledContent("Szabad hely", value: "\(shift.freePlaces) / \(shift.capacity)")
                Button("Műszak törlése", role: .destructive) {
                    viewModel.removeShift(id: shift.id)
                    selectedShiftID = nil
                }
            }
            Section("Beosztottak") {
                ForEach(workers(on: shift)) { worker in
                    HStack {
                        Text(worker.name)
                        Spacer()
                        Button("Eltávolítás", systemImage: "minus.circle", role: .destructive) {
                            viewModel.unassign(workerID: worker.id, fromShift: shift.id)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    }
                }
                Menu("Munkatárs hozzáadása") {
                    ForEach(viewModel.plan.staff.filter { !shift.workerIDs.contains($0.id) }) { worker in
                        Button(worker.name) { viewModel.assign(workerID: worker.id, toShift: shift.id) }
                    }
                }
            }
            Section("Feladatok") {
                ForEach(shift.tasks) { task in
                    LabeledContent(task.title, value: names(of: task.assignedWorkerIDs))
                }
                HStack {
                    TextField("Új feladat", text: $newTaskTitle)
                    Picker("Kinek", selection: $newTaskWorkerID) {
                        Text("–").tag(UUID?.none)
                        ForEach(workers(on: shift)) { Text($0.name).tag(Optional($0.id)) }
                    }
                    Button("Hozzáadás") {
                        guard let workerID = newTaskWorkerID else { return }
                        viewModel.addTask(titled: newTaskTitle, toShift: shift.id, for: workerID)
                        if viewModel.errorMessage == nil { newTaskTitle = "" }
                    }
                    .disabled(newTaskTitle.isEmpty || newTaskWorkerID == nil)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func workers(on shift: Shift) -> [WorkerUser] {
        viewModel.plan.staff.filter { shift.workerIDs.contains($0.id) }
    }

    private func names(of ids: [UUID]) -> String {
        let names = viewModel.plan.staff.filter { ids.contains($0.id) }.map(\.name)
        return names.isEmpty ? "–" : names.joined(separator: ", ")
    }

    private func zoneName(_ id: UUID?) -> String {
        zones.first { $0.id == id }?.name ?? "Nincs zóna"
    }

    private func timeRange(of shift: Shift) -> String {
        let start = shift.startTime.formatted(date: .abbreviated, time: .shortened)
        let end = shift.endTime.formatted(date: .omitted, time: .shortened)
        return "\(start) – \(end)"
    }
}

@L3
private struct NewShiftSheet: View {
    let zones: [Zone]
    let onSave: (Date, Date, UUID?, Int) -> Void
    @State private var start = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var end = Calendar.current.date(bySettingHour: 4, minute: 0, second: 0,
                                                   of: Date().addingTimeInterval(24 * 3600)) ?? Date()
    @State private var zoneID: UUID?
    @State private var capacity = 1
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            DatePicker("Kezdés", selection: $start)
            DatePicker("Vége", selection: $end)
            Picker("Zóna", selection: $zoneID) {
                Text("Nincs zóna").tag(UUID?.none)
                ForEach(zones) { Text($0.name).tag(Optional($0.id)) }
            }
            Stepper("Létszám: \(capacity) fő", value: $capacity, in: 1...50)
        }
        .padding()
        .frame(minWidth: 360)
        .navigationTitle("Új műszak")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Létrehozás") { onSave(start, end, zoneID, capacity); dismiss() }
            }
        }
    }
}

@L3
private struct NewWorkerSheet: View {
    static let roles: [(role: WorkerRole, title: String)] = [(.bartender, "Pultos"), (.security, "Biztonsági")]

    let onSave: (String, WorkerRole) -> Void
    @State private var name = ""
    @State private var roleIndex = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Név", text: $name)
            Picker("Munkakör", selection: $roleIndex) {
                ForEach(Self.roles.indices, id: \.self) { Text(Self.roles[$0].title).tag($0) }
            }
        }
        .padding()
        .frame(minWidth: 320)
        .navigationTitle("Új munkatárs")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") { onSave(name, Self.roles[roleIndex].role); dismiss() }.disabled(name.isEmpty)
            }
        }
    }
}
