import SwiftUI
import SharedKit

@L8
struct RequestLogView: View {
    @StateObject private var viewModel: RequestLogViewModel

    init(inventory: Inventory, staff: [WorkerUser]) {
        _viewModel = StateObject(wrappedValue: RequestLogViewModel(alerts: [], inventory: inventory, staff: staff))
    }

    var body: some View {
        List {
            ForEach(RequestLog.Category.allCases, id: \.self) { category in
                Section("\(Self.title(of: category)) (\(viewModel.count(of: category)))") {
                    let entries = viewModel.entries(in: category)
                    if entries.isEmpty {
                        Text("Nincs tétel.").foregroundStyle(.secondary)
                    }
                    ForEach(entries) { entry in
                        HStack {
                            Image(systemName: entry.isOpen ? "circle.fill" : "checkmark.circle")
                                .foregroundStyle(entry.isOpen ? .orange : .secondary)
                            VStack(alignment: .leading) {
                                Text(entry.workerName).font(.headline)
                                if !entry.details.isEmpty { Text(entry.details) }
                            }
                            Spacer()
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Kérelmek")
        .toolbar {
            Toggle("Csak a nyitottak", isOn: $viewModel.showsOnlyOpen)
        }
    }

    static func title(of category: RequestLog.Category) -> String {
        switch category {
        case .panicAlert: return "Pánikjelzések"
        case .supplyRequest: return "Készletkérések"
        }
    }
}
