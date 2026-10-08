import Foundation
import Testing
@testable import SharedKit

@Suite("Inventory")
@L10 @K17
struct InventoryTests {

    private func inventory() throws -> (Inventory, SupplyItem) {
        var inventory = Inventory()
        let ice = try inventory.addItem(named: "Ice", category: "Bar", quantity: 20, unit: "kg", minimum: 10)
        try inventory.addItem(named: "Cups", category: "Bar", quantity: 500, unit: "piece", minimum: 100)
        return (inventory, ice)
    }

    @Test func itemsAreListedByName() throws {
        let (inventory, _) = try inventory()
        #expect(inventory.items.map(\.name) == ["Cups", "Ice"])
    }

    @Test func itemNamesAreUniqueIgnoringCase() throws {
        var (inventory, _) = try inventory()
        #expect(throws: Inventory.InventoryError.duplicateItem("ice")) {
            try inventory.addItem(named: "ice", category: "Bar", quantity: 1, unit: "kg", minimum: 0)
        }
    }

    @Test func itemNeedsNameAndNonNegativeAmounts() throws {
        var inventory = Inventory()
        #expect(throws: Inventory.InventoryError.emptyName) {
            try inventory.addItem(named: " ", category: "Bar", quantity: 1, unit: "kg", minimum: 0)
        }
        #expect(throws: Inventory.InventoryError.negativeAmount) {
            try inventory.addItem(named: "Ice", category: "Bar", quantity: -1, unit: "kg", minimum: 0)
        }
        #expect(throws: Inventory.InventoryError.negativeAmount) {
            try inventory.addItem(named: "Ice", category: "Bar", quantity: 1, unit: "kg", minimum: -5)
        }
    }

    @Test func lowStockIsBelowTheMinimum() throws {
        var (inventory, ice) = try inventory()
        try inventory.setQuantity(10, ofItem: ice.id)
        #expect(inventory.lowStockItems.isEmpty)
        try inventory.setQuantity(9, ofItem: ice.id)
        #expect(inventory.lowStockItems.map(\.name) == ["Ice"])
    }

    @Test func approvingTakesFromTheStock() throws {
        var (inventory, ice) = try inventory()
        let request = try inventory.receiveRequest(from: UUID(), itemID: ice.id, quantity: 4)
        #expect(inventory.pendingRequests.map(\.id) == [request.id])
        let item = try inventory.approveRequest(id: request.id)
        #expect(item.quantity == 16)
        #expect(inventory.requests.first?.status == .approved)
        #expect(inventory.pendingRequests.isEmpty)
    }

    @Test func requestLargerThanTheStockIsNotApproved() throws {
        var (inventory, ice) = try inventory()
        let request = try inventory.receiveRequest(from: UUID(), itemID: ice.id, quantity: 25)
        #expect(throws: Inventory.InventoryError.notEnoughStock("Ice")) {
            try inventory.approveRequest(id: request.id)
        }
        #expect(inventory.requests.first?.status == .pending)
    }

    @Test func rejectingKeepsTheStock() throws {
        var (inventory, ice) = try inventory()
        let request = try inventory.receiveRequest(from: UUID(), itemID: ice.id, quantity: 4)
        try inventory.rejectRequest(id: request.id)
        #expect(inventory.requests.first?.status == .rejected)
        #expect(inventory.items.first { $0.id == ice.id }?.quantity == 20)
    }

    @Test func onlyPendingRequestsCanBeDecided() throws {
        var (inventory, ice) = try inventory()
        let request = try inventory.receiveRequest(from: UUID(), itemID: ice.id, quantity: 4)
        try inventory.rejectRequest(id: request.id)
        #expect(throws: Inventory.InventoryError.alreadyDecided) { try inventory.approveRequest(id: request.id) }
    }

    @Test func requestNeedsAPositiveQuantityAndAKnownItem() throws {
        var (inventory, ice) = try inventory()
        #expect(throws: Inventory.InventoryError.negativeAmount) {
            try inventory.receiveRequest(from: UUID(), itemID: ice.id, quantity: 0)
        }
        #expect(throws: Inventory.InventoryError.unknownItem) {
            try inventory.receiveRequest(from: UUID(), itemID: UUID(), quantity: 1)
        }
    }

    @Test func statusDisplayNames() {
        #expect([SupplyRequestStatus.pending, .approved, .rejected].map(\.displayName) == ["pending", "approved", "rejected"])
    }
}
