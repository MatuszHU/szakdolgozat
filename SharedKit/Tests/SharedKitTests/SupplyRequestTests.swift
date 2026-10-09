import Foundation
import Testing
@testable import SharedKit

@Suite("Supply requests from workers")
@K17
struct SupplyRequestTests {
    private let anna = UUID()
    private let bela = UUID()
    private let base = Date(timeIntervalSince1970: 1_800_000_000)

    private func stock() throws -> (Inventory, ice: SupplyItem, lime: SupplyItem) {
        var inventory = Inventory()
        let ice = try inventory.addItem(named: "Ice", category: "Bar", quantity: 20, unit: "kg", minimum: 5)
        try inventory.addItem(named: "Glasses", category: "Bar", quantity: 100, unit: "pcs", minimum: 40)
        let lime = try inventory.addItem(named: "Lime", category: "Fruit", quantity: 3, unit: "kg", minimum: 1)
        return (inventory, ice, lime)
    }

    @Test func aRequestKeepsUrgencyAndZone() throws {
        var (inventory, ice, _) = try stock()
        let bar = UUID()
        let request = try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 5, urgency: .outOfStock,
                                                   zoneID: bar, note: "Fridge empty", at: base)
        #expect(request.urgency == .outOfStock)
        #expect(request.zoneID == bar)
        #expect(request.note == "Fridge empty")
        #expect(inventory.pendingRequests == [request])
    }

    @Test func theDefaultUrgencyIsRunningLow() throws {
        var (inventory, ice, _) = try stock()
        #expect(try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 1).urgency == .runningLow)
    }

    @Test func onlyOneOpenRequestPerWorkerAndItem() throws {
        var (inventory, ice, _) = try stock()
        try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 5)
        #expect(throws: Inventory.InventoryError.openRequestExists("Ice")) {
            try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 3)
        }
        try inventory.receiveRequest(from: bela, itemID: ice.id, quantity: 3)
        #expect(inventory.pendingRequests.count == 2)
    }

    @Test func aDecidedRequestAllowsANewOne() throws {
        var (inventory, ice, _) = try stock()
        let first = try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 5)
        try inventory.rejectRequest(id: first.id)
        try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 3)
        #expect(inventory.pendingRequests.count == 1)
    }

    @Test func myRequestsAreNewestFirstAndOnlyMine() throws {
        var (inventory, ice, lime) = try stock()
        let older = try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 5, at: base)
        try inventory.receiveRequest(from: bela, itemID: lime.id, quantity: 1, at: base.addingTimeInterval(30))
        let newer = try inventory.receiveRequest(from: anna, itemID: lime.id, quantity: 2, at: base.addingTimeInterval(60))
        #expect(inventory.requests(of: anna).map(\.id) == [newer.id, older.id])
    }

    @Test func itemsAreGroupedByCategory() throws {
        let (inventory, _, _) = try stock()
        #expect(inventory.categories.map(\.name) == ["Bar", "Fruit"])
        #expect(inventory.categories.map { $0.items.map(\.name) } == [["Glasses", "Ice"], ["Lime"]])
    }

    @Test func anOldSavedRequestLoadsWithDefaults() throws {
        let json = """
        {"id":"7F1C2C55-0C0B-4E48-9B4B-5B2E3E1D0A11","workerID":"7F1C2C55-0C0B-4E48-9B4B-5B2E3E1D0A12",
         "itemID":"7F1C2C55-0C0B-4E48-9B4B-5B2E3E1D0A13","quantity":4,"requestDate":0,"status":{"pending":{}}}
        """
        let request = try JSONDecoder().decode(SupplyRequest.self, from: Data(json.utf8))
        #expect(request.urgency == .runningLow)
        #expect(request.zoneID == nil)
    }

    @Test func theRequestLogMarksUrgentRequests() throws {
        var (inventory, ice, lime) = try stock()
        try inventory.receiveRequest(from: anna, itemID: ice.id, quantity: 5, urgency: .outOfStock, at: base)
        try inventory.receiveRequest(from: anna, itemID: lime.id, quantity: 1, urgency: .runningLow,
                                     at: base.addingTimeInterval(60))
        let log = RequestLog(alerts: [], inventory: inventory, staff: [])
        #expect(log.entries.map(\.isUrgent) == [false, true])
    }
}
