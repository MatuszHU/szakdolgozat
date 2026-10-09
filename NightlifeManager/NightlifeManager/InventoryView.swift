import SwiftUI
import SharedKit

@L10 @K17
struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var showingNewItem = false

    var body: some View {
        Form {
            if let warning = viewModel.lowStockWarning {
                Label(warning, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
            }
            if !viewModel.inventory.lowStockItems.isEmpty {
                Section("Alacsony készlet") {
                    ForEach(viewModel.inventory.lowStockItems) { item in
                        LabeledContent(item.name, value: "\(Self.amount(item.quantity)) / min. \(Self.amount(item.minimumQuantity)) \(item.unit)")
                            .foregroundStyle(.orange)
                    }
                }
            }
            Section("Függő kérések") {
                if viewModel.inventory.pendingRequests.isEmpty {
                    Text("Nincs elbírálásra váró kérés.").foregroundStyle(.secondary)
                }
                ForEach(viewModel.inventory.pendingRequests) { request in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(viewModel.item(for: request)?.name ?? "?") · \(Self.amount(request.quantity)) \(viewModel.item(for: request)?.unit ?? "")")
                            if let note = request.note {
                                Text(note).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        if request.urgency == .outOfStock {
                            Text("Elfogyott").font(.caption.bold()).foregroundStyle(.red)
                        }
                        Spacer()
                        Button("Elutasítás") { viewModel.rejectRequest(id: request.id) }
                        Button("Jóváhagyás") { viewModel.approveRequest(id: request.id) }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            Section("Készlet") {
                ForEach(viewModel.inventory.items) { item in
                    StockRow(item: item) { viewModel.setQuantity($0, ofItem: item.id) }
                }
            }
            if let message = viewModel.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Készlet")
        .toolbar {
            Button("Új tétel", systemImage: "plus") { showingNewItem = true }
        }
        .sheet(isPresented: $showingNewItem) {
            NewStockItemSheet { name, category, quantity, unit, minimum in
                viewModel.addItem(named: name, category: category, quantity: quantity, unit: unit, minimum: minimum)
            }
        }
    }

    static func amount(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}

@L10
private struct StockRow: View {
    let item: SupplyItem
    let onChange: (Double) -> Void
    @State private var quantity: Double = 0

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                Text("\(item.category) · min. \(InventoryView.amount(item.minimumQuantity)) \(item.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TextField("Mennyiség", value: $quantity, format: .number)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
                .onSubmit { onChange(quantity) }
            Text(item.unit).foregroundStyle(.secondary)
        }
        .onAppear { quantity = item.quantity }
        .onChange(of: item.quantity) { quantity = item.quantity }
    }
}

@L10
private struct NewStockItemSheet: View {
    let onSave: (String, String, Double, String, Double) -> Void
    @State private var name = ""
    @State private var category = ""
    @State private var quantity: Double = 0
    @State private var unit = ""
    @State private var minimum: Double = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Megnevezés", text: $name)
            TextField("Kategória", text: $category)
            TextField("Mennyiség", value: $quantity, format: .number)
            TextField("Mértékegység", text: $unit)
            TextField("Minimális mennyiség", value: $minimum, format: .number)
        }
        .padding()
        .frame(minWidth: 360)
        .navigationTitle("Új készlettétel")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") { onSave(name, category, quantity, unit, minimum); dismiss() }
                    .disabled(name.isEmpty || unit.isEmpty)
            }
        }
    }
}
