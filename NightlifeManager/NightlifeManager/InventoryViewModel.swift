import Foundation
import Combine
import SharedKit

@L10
protocol InventoryStoring {
    func load() -> Inventory?
    func save(_ inventory: Inventory) throws
}

@L10 @K17
class InventoryViewModel: ObservableObject {
    @Published private(set) var inventory: Inventory
    @Published private(set) var errorMessage: String?
    @Published private(set) var lowStockWarning: String?
    private let store: InventoryStoring

    init(inventory: Inventory, store: InventoryStoring) {
        self.inventory = inventory
        self.store = store
    }

    func addItem(named name: String, category: String, quantity: Double, unit: String, minimum: Double) {
        apply { _ = try $0.addItem(named: name, category: category, quantity: quantity, unit: unit, minimum: minimum) }
    }

    func removeItem(id: UUID) {
        apply { $0.removeItem(id: id) }
    }

    func setQuantity(_ quantity: Double, ofItem itemID: UUID) {
        apply { try warnIfLow($0.setQuantity(quantity, ofItem: itemID)) }
    }

    @discardableResult
    func receiveRequest(from workerID: UUID, itemID: UUID, quantity: Double) -> UUID? {
        var created: SupplyRequest?
        apply { created = try $0.receiveRequest(from: workerID, itemID: itemID, quantity: quantity) }
        return created?.id
    }

    func approveRequest(id: UUID) {
        apply { try warnIfLow($0.approveRequest(id: id)) }
    }

    func rejectRequest(id: UUID) {
        apply { try $0.rejectRequest(id: id) }
    }

    func item(for request: SupplyRequest) -> SupplyItem? {
        inventory.items.first { $0.id == request.itemID }
    }

    private func warnIfLow(_ item: SupplyItem) {
        lowStockWarning = item.quantity < item.minimumQuantity ? "\(item.name) is running low" : nil
    }

    private func apply(_ edit: (inout Inventory) throws -> Void) {
        var edited = inventory
        do {
            try edit(&edited)
            inventory = edited
            errorMessage = nil
            try store.save(edited)
        } catch let error as Inventory.InventoryError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "The stock could not be saved"
        }
    }

    private static func message(for error: Inventory.InventoryError) -> String {
        switch error {
        case .emptyName: return "A name is required"
        case .negativeAmount: return "Quantities must be positive"
        case .duplicateItem(let name): return "\(name) is already in the stock"
        case .unknownItem: return "The item no longer exists"
        case .unknownRequest: return "The request no longer exists"
        case .alreadyDecided: return "The request has already been decided"
        case .notEnoughStock(let name): return "Not enough \(name) in stock"
        }
    }
}
