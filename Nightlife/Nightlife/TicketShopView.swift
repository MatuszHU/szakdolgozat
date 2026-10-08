import SwiftUI
import SharedKit

@M4
struct TicketShopView: View {
    @ObservedObject var viewModel: TicketShopViewModel

    var body: some View {
        Group {
            if viewModel.eventsOnSale.isEmpty {
                ContentUnavailableView("Nincs elérhető esemény",
                                       systemImage: "ticket",
                                       description: Text("Amint új esemény kerül meghirdetésre, itt vásárolhatsz rá jegyet."))
            } else {
                List(viewModel.eventsOnSale) { event in
                    NavigationLink {
                        EventTicketsView(viewModel: viewModel, event: event)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(event.title).font(.headline)
                            Text(event.startTime.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Jegyvásárlás")
    }
}

@M4
private struct EventTicketsView: View {
    @ObservedObject var viewModel: TicketShopViewModel
    let event: Event
    @State private var quantity = 1

    var body: some View {
        Form {
            Section {
                LabeledContent("Időpont", value: event.startTime.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Helyszín", value: event.location.isEmpty ? "–" : event.location)
            }
            Section("Darabszám") {
                Stepper("\(quantity) db", value: $quantity, in: 1...10)
            }
            Section("Jegytípusok") {
                ForEach(event.ticketOffers) { offer in
                    Button {
                        viewModel.buy(offer.type, quantity: quantity, forEvent: event.id)
                    } label: {
                        LabeledContent(offer.type.displayName, value: "\(Int(offer.price) * quantity) Ft")
                    }
                }
            }
            if let message = viewModel.errorMessage {
                Section {
                    Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(event.title)
    }
}
