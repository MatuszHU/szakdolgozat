import SwiftUI
import SharedKit

@K17
struct SupplyRequestView: View {
    @ObservedObject var viewModel: SupplyRequestViewModel
    @State private var itemID: UUID?
    @State private var quantity = 1
    @State private var urgency = SupplyUrgency.runningLow
    @State private var note = ""

    var body: some View {
        Form {
            if viewModel.categories.isEmpty {
                ContentUnavailableView("Nincs készletlista",
                                       systemImage: "shippingbox",
                                       description: Text("A készletlistát az adminisztrátor állítja össze."))
            } else {
                Section("Mi fogy?") {
                    Picker("Tétel", selection: $itemID) {
                        Text("Válassz…").tag(UUID?.none)
                        ForEach(viewModel.categories) { category in
                            Section(category.name) {
                                ForEach(category.items) { item in
                                    Text(item.name).tag(Optional(item.id))
                                }
                            }
                        }
                    }
                    Stepper("Mennyiség: \(quantity) \(unit)", value: $quantity, in: 1...999)
                    Picker("Állapot", selection: $urgency) {
                        Text("Hamarosan elfogy").tag(SupplyUrgency.runningLow)
                        Text("Elfogyott").tag(SupplyUrgency.outOfStock)
                    }
                    .pickerStyle(.segmented)
                    TextField("Megjegyzés (nem kötelező)", text: $note)
                }
                Section {
                    Button("Kérés küldése") {
                        guard let itemID else { return }
                        viewModel.request(itemID: itemID, quantity: Double(quantity), urgency: urgency, note: note)
                        if !viewModel.isError { note = "" }
                    }
                    .disabled(itemID == nil)
                    if let message = viewModel.message {
                        Text(message).foregroundStyle(viewModel.isError ? .red : .green)
                    }
                }
            }
            if !viewModel.myRequests.isEmpty {
                Section("Kéréseim") {
                    ForEach(viewModel.myRequests) { request in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(request.itemName) · \(request.amount)")
                                if request.urgency == .outOfStock {
                                    Text("Elfogyott").font(.caption).foregroundStyle(.red)
                                }
                            }
                            Spacer()
                            Text(Self.title(of: request.status)).foregroundStyle(Self.color(of: request.status))
                        }
                    }
                }
            }
        }
        .navigationTitle("Készletkérés")
        .onAppear { viewModel.refresh() }
    }

    private var unit: String {
        viewModel.categories.flatMap(\.items).first { $0.id == itemID }?.unit ?? ""
    }

    private static func title(of status: SupplyRequestStatus) -> LocalizedStringKey {
        switch status {
        case .pending: return "Függőben"
        case .approved: return "Jóváhagyva"
        case .rejected: return "Elutasítva"
        }
    }

    private static func color(of status: SupplyRequestStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}
