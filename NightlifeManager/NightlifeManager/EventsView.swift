import SwiftUI
import SharedKit

@L11
struct EventsView: View {
    @ObservedObject var viewModel: EventManagerViewModel
    let defaultLocation: String
    @State private var selectedEventID: UUID?
    @State private var showingNewEvent = false

    private var selectedEvent: Event? { viewModel.catalog.events.first { $0.id == selectedEventID } }

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $selectedEventID) {
                if viewModel.catalog.events.isEmpty {
                    Text("Még nincs esemény.").foregroundStyle(.secondary)
                }
                ForEach(viewModel.catalog.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.title).font(.headline)
                        Text(event.startTime.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(.secondary)
                    }
                    .tag(event.id)
                }
            }
            .frame(width: 280)
            Divider()
            VStack(alignment: .leading) {
                if let event = selectedEvent {
                    EventDetailView(viewModel: viewModel, event: event) { selectedEventID = nil }
                } else {
                    ContentUnavailableView("Válassz egy eseményt", systemImage: "ticket")
                }
                if let message = viewModel.errorMessage {
                    Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red).padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Események")
        .toolbar {
            Button("Új esemény", systemImage: "plus") { showingNewEvent = true }
        }
        .sheet(isPresented: $showingNewEvent) {
            NewEventSheet(location: defaultLocation) { title, location, start, end, capacity in
                selectedEventID = viewModel.createEvent(titled: title, location: location,
                                                        from: start, to: end, capacity: capacity)?.id
            }
        }
    }
}

@L11 @M4 @M7
private struct EventDetailView: View {
    @ObservedObject var viewModel: EventManagerViewModel
    let event: Event
    let onDelete: () -> Void
    @State private var offerKind = 0
    @State private var customName = ""
    @State private var price = 0
    @State private var hasQuota = false
    @State private var quota = 50
    @State private var raffleTitle = ""
    @State private var rafflePrize = ""

    private static let kinds = ["Standard", "VIP", "Egyéb"]

    var body: some View {
        Form {
            Section("Esemény") {
                LabeledContent("Időpont", value: "\(event.startTime.formatted(date: .abbreviated, time: .shortened)) – \(event.endTime.formatted(date: .omitted, time: .shortened))")
                LabeledContent("Helyszín", value: event.location.isEmpty ? "–" : event.location)
                LabeledContent("Férőhely", value: "\(event.capacity) fő")
                Button("Esemény törlése", role: .destructive) {
                    viewModel.removeEvent(id: event.id)
                    onDelete()
                }
            }
            Section("Jegytípusok") {
                ForEach(event.ticketOffers) { offer in
                    HStack {
                        Text(offer.type.displayName)
                        Spacer()
                        Text("\(Int(offer.price)) Ft" + (offer.quota.map { " · \($0) hely" } ?? ""))
                            .foregroundStyle(.secondary)
                        Button("Törlés", systemImage: "trash", role: .destructive) {
                            viewModel.removeTicketOffer(id: offer.id, fromEvent: event.id)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    }
                }
                Picker("Típus", selection: $offerKind) {
                    ForEach(Self.kinds.indices, id: \.self) { Text(Self.kinds[$0]).tag($0) }
                }
                if offerKind == 2 {
                    TextField("Megnevezés", text: $customName)
                }
                TextField("Ár (Ft)", value: $price, format: .number)
                Toggle("Korlátozott keret", isOn: $hasQuota)
                if hasQuota {
                    Stepper("Keret: \(quota) hely", value: $quota, in: 1...event.capacity)
                }
                Button("Jegytípus hozzáadása") {
                    let type: TicketType = offerKind == 0 ? .standard : offerKind == 1 ? .vip : .custom(customName)
                    viewModel.offerTickets(type, price: Double(price), quota: hasQuota ? quota : nil, forEvent: event.id)
                }
                .disabled(offerKind == 2 && customName.isEmpty)
            }
            Section("Nyereményjáték") {
                if let raffle = event.raffle {
                    LabeledContent(raffle.title, value: raffle.prize)
                    LabeledContent("Jelentkezők", value: "\(raffle.participantIDs.count)")
                    Button("Nyereményjáték törlése", role: .destructive) { viewModel.removeRaffle(fromEvent: event.id) }
                } else {
                    TextField("Megnevezés", text: $raffleTitle)
                    TextField("Nyeremény", text: $rafflePrize)
                    Button("Meghirdetés") {
                        viewModel.announceRaffle(titled: raffleTitle, prize: rafflePrize, forEvent: event.id)
                    }
                    .disabled(raffleTitle.isEmpty || rafflePrize.isEmpty)
                }
            }
        }
        .formStyle(.grouped)
    }
}

@L11
private struct NewEventSheet: View {
    let onSave: (String, String, Date, Date, Int) -> Void
    @State private var title = ""
    @State private var location: String
    @State private var start = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var end = Calendar.current.date(bySettingHour: 4, minute: 0, second: 0,
                                                   of: Date().addingTimeInterval(24 * 3600)) ?? Date()
    @State private var capacity = 200
    @Environment(\.dismiss) private var dismiss

    init(location: String, onSave: @escaping (String, String, Date, Date, Int) -> Void) {
        _location = State(initialValue: location)
        self.onSave = onSave
    }

    var body: some View {
        Form {
            TextField("Cím", text: $title)
            TextField("Helyszín", text: $location)
            DatePicker("Kezdés", selection: $start)
            DatePicker("Vége", selection: $end)
            Stepper("Férőhely: \(capacity) fő", value: $capacity, in: 1...10_000, step: 10)
        }
        .padding()
        .frame(minWidth: 380)
        .navigationTitle("Új esemény")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Létrehozás") { onSave(title, location, start, end, capacity); dismiss() }.disabled(title.isEmpty)
            }
        }
    }
}
