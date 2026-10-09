import Foundation
import Combine
import SharedKit

@K17
protocol SupplyDesk: AnyObject {
    var inventory: Inventory { get }
    func submit(from workerID: UUID, itemID: UUID, quantity: Double, urgency: SupplyUrgency,
                zoneID: UUID?, note: String?) throws -> SupplyRequest
}

@K17
final class LocalSupplyDesk: SupplyDesk {
    private(set) var inventory: Inventory
    private let now: () -> Date

    init(inventory: Inventory = Inventory(), now: @escaping () -> Date = Date.init) {
        self.inventory = inventory
        self.now = now
    }

    func submit(from workerID: UUID, itemID: UUID, quantity: Double, urgency: SupplyUrgency,
                zoneID: UUID?, note: String?) throws -> SupplyRequest {
        try inventory.receiveRequest(from: workerID, itemID: itemID, quantity: quantity, urgency: urgency,
                                     zoneID: zoneID, note: note, at: now())
    }

    func decide(_ requestID: UUID, approve: Bool) throws {
        if approve {
            try inventory.approveRequest(id: requestID)
        } else {
            try inventory.rejectRequest(id: requestID)
        }
    }
}

@K17
class SupplyRequestViewModel: ObservableObject {
    struct MyRequest: Identifiable {
        let id: UUID
        let itemName: String
        let amount: String
        let urgency: SupplyUrgency
        let status: SupplyRequestStatus
    }

    @Published private(set) var message: String?
    @Published private(set) var isError = false
    @Published private(set) var myRequests: [MyRequest] = []
    private let workerID: UUID
    private let zoneID: UUID?
    private let desk: SupplyDesk
    private let isEnabled: Bool

    init(workerID: UUID, zoneID: UUID?, desk: SupplyDesk, isEnabled: Bool = true) {
        self.workerID = workerID
        self.zoneID = zoneID
        self.desk = desk
        self.isEnabled = isEnabled
        refresh()
    }

    var categories: [Inventory.Category] { desk.inventory.categories }

    func request(itemID: UUID, quantity: Double, urgency: SupplyUrgency, note: String = "") {
        guard isEnabled else { return fail("Supply requests are turned off") }
        let note = note.trimmingCharacters(in: .whitespaces)
        do {
            _ = try desk.submit(from: workerID, itemID: itemID, quantity: quantity, urgency: urgency, zoneID: zoneID,
                                note: note.isEmpty ? nil : note)
            message = "Request sent"
            isError = false
        } catch let error as Inventory.InventoryError {
            fail(Self.message(for: error))
        } catch {
            fail("The request could not be sent")
        }
        refresh()
    }

    func refresh() {
        let items = desk.inventory.items
        myRequests = desk.inventory.requests(of: workerID).map { request in
            let item = items.first { $0.id == request.itemID }
            let amount = request.quantity.formatted(.number.precision(.fractionLength(0...2)))
            return MyRequest(id: request.id, itemName: item?.name ?? "?", amount: "\(amount) \(item?.unit ?? "")",
                             urgency: request.urgency, status: request.status)
        }
    }

    private func fail(_ text: String) {
        message = text
        isError = true
    }

    private static func message(for error: Inventory.InventoryError) -> String {
        switch error {
        case .negativeAmount: return "Enter a quantity greater than zero"
        case .openRequestExists(let name): return "You already have an open request for \(name)"
        case .unknownItem: return "The item is no longer available"
        default: return "The request could not be sent"
        }
    }
}
