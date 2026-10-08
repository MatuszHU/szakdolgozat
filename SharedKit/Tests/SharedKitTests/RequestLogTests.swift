import Foundation
import Testing
@testable import SharedKit

@Suite("RequestLog")
@L8 @K8 @K17
struct RequestLogTests {

    private let base = Date(timeIntervalSince1970: 1_800_000_000)
    private let anna = WorkerUser(appleID: "a", name: "Anna", role: .bartender, payPeriod: .weekly)
    private let bela = WorkerUser(appleID: "b", name: "Béla", role: .security, payPeriod: .weekly)

    private func sources() throws -> ([PanicAlert], Inventory) {
        var inventory = Inventory()
        let ice = try inventory.addItem(named: "Ice", category: "Bar", quantity: 20, unit: "kg", minimum: 5)
        try inventory.receiveRequest(from: bela.id, itemID: ice.id, quantity: 4, at: base)
        let annas = try inventory.receiveRequest(from: anna.id, itemID: ice.id, quantity: 2, at: base.addingTimeInterval(1800))
        try inventory.approveRequest(id: annas.id)
        let alert = PanicAlert(workerID: anna.id, timestamp: base.addingTimeInterval(4200))
        return ([alert], inventory)
    }

    @Test func entriesAreNewestFirstWithDetails() throws {
        let (alerts, inventory) = try sources()
        let log = RequestLog(alerts: alerts, inventory: inventory, staff: [anna, bela])
        #expect(log.entries.map(\.category) == [.panicAlert, .supplyRequest, .supplyRequest])
        #expect(log.entries.map(\.workerName) == ["Anna", "Anna", "Béla"])
        #expect(log.entries.map(\.details) == ["", "2 kg Ice", "4 kg Ice"])
        #expect(log.entries.map(\.isOpen) == [true, false, true])
    }

    @Test func countsPerCategory() throws {
        let (alerts, inventory) = try sources()
        let log = RequestLog(alerts: alerts, inventory: inventory, staff: [anna, bela])
        #expect(log.count(of: .panicAlert) == 1)
        #expect(log.count(of: .supplyRequest) == 2)
        #expect(log.openEntries.count == 2)
    }

    @Test func acknowledgedAlertIsClosed() throws {
        var (alerts, inventory) = try sources()
        _ = alerts[0].acknowledge(by: bela.id)
        let log = RequestLog(alerts: alerts, inventory: inventory, staff: [anna, bela])
        #expect(log.entries.first?.isOpen == false)
    }

    @Test func unknownWorkerIsShownAsUnknown() throws {
        let log = RequestLog(alerts: [PanicAlert(workerID: UUID(), timestamp: base)], inventory: Inventory(), staff: [])
        #expect(log.entries.first?.workerName == "Unknown worker")
    }

    @Test func categoryNames() {
        #expect(RequestLog.Category.allCases.map(\.displayName) == ["Panic alert", "Supply request"])
    }
}
