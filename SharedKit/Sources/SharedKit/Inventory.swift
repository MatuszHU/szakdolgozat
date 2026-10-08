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
                                        note: String? = nil, at date: Date = Date()) throws -> SupplyRequest {
        guard quantity > 0 else { throw InventoryError.negativeAmount }
        guard items.contains(where: { $0.id == itemID }) else { throw InventoryError.unknownItem }
        let request = SupplyRequest(workerID: workerID, itemID: itemID, quantity: quantity, requestDate: date, note: note)
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
