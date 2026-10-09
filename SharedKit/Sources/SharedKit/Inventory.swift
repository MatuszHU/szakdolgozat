import Foundation

extension SupplyRequestStatus {
    @L10 @K17
    public var displayName: String {
        switch self {
        case .pending: return "pending"
        case .approved: return "approved"
        case .rejected: return "rejected"
        }
    }
}

@L10 @K17
public struct Inventory: Codable, Hashable {
    public enum InventoryError: Error, Equatable {
        case emptyName
        case negativeAmount
        case duplicateItem(String)
        case unknownItem
        case unknownRequest
        case alreadyDecided
        case notEnoughStock(String)
        case openRequestExists(String)
    }

    public struct Category: Identifiable, Hashable {
        public let name: String
        public let items: [SupplyItem]

        public var id: String { name }
    }

    public private(set) var items: [SupplyItem] = []
    public private(set) var requests: [SupplyRequest] = []

    public init() {}

    public var lowStockItems: [SupplyItem] {
        items.filter { $0.quantity < $0.minimumQuantity }
    }

    public var pendingRequests: [SupplyRequest] {
        requests.filter { $0.status == .pending }
    }

    @K17
    public var categories: [Category] {
        Dictionary(grouping: items, by: \.category)
            .map { Category(name: $0.key, items: $0.value) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    @K17
    public func requests(of workerID: UUID) -> [SupplyRequest] {
        requests.filter { $0.workerID == workerID }.sorted { $0.requestDate > $1.requestDate }
    }

    @discardableResult
    public mutating func addItem(named name: String, category: String, quantity: Double, unit: String,
                                 minimum: Double) throws -> SupplyItem {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw InventoryError.emptyName }
        guard quantity >= 0, minimum >= 0 else { throw InventoryError.negativeAmount }
        guard !items.contains(where: { $0.name.lowercased() == name.lowercased() }) else {
            throw InventoryError.duplicateItem(name)
        }
        let item = SupplyItem(name: name, category: category, quantity: quantity, unit: unit, minimumQuantity: minimum)
        items.append(item)
        items.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        return item
    }

    public mutating func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    @discardableResult
    public mutating func setQuantity(_ quantity: Double, ofItem itemID: UUID) throws -> SupplyItem {
        guard quantity >= 0 else { throw InventoryError.negativeAmount }
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { throw InventoryError.unknownItem }
        items[index].quantity = quantity
        return items[index]
    }

    @discardableResult
    public mutating func receiveRequest(from workerID: UUID, itemID: UUID, quantity: Double,
                                        urgency: SupplyUrgency = .runningLow, zoneID: UUID? = nil,
                                        note: String? = nil, at date: Date = Date()) throws -> SupplyRequest {
        guard quantity > 0 else { throw InventoryError.negativeAmount }
        guard let item = items.first(where: { $0.id == itemID }) else { throw InventoryError.unknownItem }
        guard !pendingRequests.contains(where: { $0.workerID == workerID && $0.itemID == itemID }) else {
            throw InventoryError.openRequestExists(item.name)
        }
        let request = SupplyRequest(workerID: workerID, itemID: itemID, quantity: quantity, requestDate: date,
                                    note: note, urgency: urgency, zoneID: zoneID)
        requests.append(request)
        return request
    }

    @discardableResult
    public mutating func approveRequest(id: UUID) throws -> SupplyItem {
        let index = try pendingIndex(of: id)
        guard let itemIndex = items.firstIndex(where: { $0.id == requests[index].itemID }) else {
            throw InventoryError.unknownItem
        }
        guard items[itemIndex].quantity >= requests[index].quantity else {
            throw InventoryError.notEnoughStock(items[itemIndex].name)
        }
        items[itemIndex].quantity -= requests[index].quantity
        requests[index].status = .approved
        return items[itemIndex]
    }

    public mutating func rejectRequest(id: UUID) throws {
        let index = try pendingIndex(of: id)
        requests[index].status = .rejected
    }

    private func pendingIndex(of requestID: UUID) throws -> Int {
        guard let index = requests.firstIndex(where: { $0.id == requestID }) else { throw InventoryError.unknownRequest }
        guard requests[index].status == .pending else { throw InventoryError.alreadyDecided }
        return index
    }
}
