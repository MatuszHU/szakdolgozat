import Foundation

@L8 @K8 @K17
public struct RequestLog {
    public enum Category: CaseIterable, Hashable, Sendable {
        case panicAlert
        case supplyRequest

        public var displayName: String {
            switch self {
            case .panicAlert: return "Panic alert"
            case .supplyRequest: return "Supply request"
            }
        }
    }

    public struct Entry: Identifiable, Hashable {
        public let id: UUID
        public let category: Category
        public let date: Date
        public let workerName: String
        public let details: String
        public let isOpen: Bool
    }

    public let entries: [Entry]

    public init(alerts: [PanicAlert], inventory: Inventory, staff: [WorkerUser]) {
        func name(of workerID: UUID) -> String {
            staff.first { $0.id == workerID }?.name ?? "Unknown worker"
        }
        let alertEntries = alerts.map {
            Entry(id: $0.id, category: .panicAlert, date: $0.timestamp, workerName: name(of: $0.workerID),
                  details: "", isOpen: !$0.isAcknowledged)
        }
        let supplyEntries = inventory.requests.map { request in
            let item = inventory.items.first { $0.id == request.itemID }
            let amount = request.quantity.formatted(.number.precision(.fractionLength(0...2)))
            return Entry(id: request.id, category: .supplyRequest, date: request.requestDate,
                         workerName: name(of: request.workerID),
                         details: "\(amount) \(item?.unit ?? "") \(item?.name ?? "")",
                         isOpen: request.status == .pending)
        }
        entries = (alertEntries + supplyEntries).sorted { $0.date > $1.date }
    }

    public var openEntries: [Entry] {
        entries.filter(\.isOpen)
    }

    public func count(of category: Category, openOnly: Bool = false) -> Int {
        (openOnly ? openEntries : entries).filter { $0.category == category }.count
    }
}
