import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    @K17
    func setupSupplyRequestSteps() {
        var desk: LocalSupplyDesk!
        var me: WorkerUser!
        var zone: Zone!
        var viewModel: SupplyRequestViewModel!

        func item(named name: String) throws -> SupplyItem {
            try XCTUnwrap(desk.inventory.items.first { $0.name == name }, "Unknown item in scenario: \(name)")
        }

        func urgency(_ text: String) -> SupplyUrgency {
            text == "out of stock" ? .outOfStock : .runningLow
        }

        func openRequest() {
            if viewModel == nil {
                viewModel = SupplyRequestViewModel(workerID: me.id, zoneID: zone.id, desk: desk,
                                                   isEnabled: World.enabledFeatures.contains(.supplyRequests))
            }
        }

        func request(_ match: Match) throws {
            openRequest()
            let texts = try match.allParameters(\.string)
            viewModel.request(itemID: try item(named: texts[0]).id, quantity: Double(try match.first(\.int)),
                              urgency: urgency(texts[1]))
        }

        BeforeScenario { _ in
            var tick = Date(timeIntervalSince1970: 1_800_000_000)
            desk = LocalSupplyDesk(now: {
                tick = tick.addingTimeInterval(60)
                return tick
            })
            viewModel = nil
        }

        Given("the stock list has:") { _, step in
            var inventory = Inventory()
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                try inventory.addItem(named: row[0], category: row[1], quantity: 100, unit: row[2], minimum: 0)
            }
            var tick = Date(timeIntervalSince1970: 1_800_000_000)
            desk = LocalSupplyDesk(inventory: inventory, now: {
                tick = tick.addingTimeInterval(60)
                return tick
            })
        }

        Given("I am {string} working in the {string} zone") { match, _ in
            let names = try match.allParameters(\.string)
            me = WorkerUser(appleID: names[0], name: names[0], role: .bartender, payPeriod: .weekly)
            zone = Zone(name: names[1])
        }

        Given("I requested {int} of {string} because it is {string}") { match, _ in
            try request(match)
            XCTAssertEqual(english(viewModel.message), "Request sent")
        }

        When("I open the supply request") { _, _ in
            openRequest()
        }

        When("I request {int} of {string} because it is {string}") { match, _ in
            try request(match)
        }

        func decide(_ match: Match, approve: Bool) throws {
            let itemID = try item(named: try match.first(\.string)).id
            try desk.decide(try XCTUnwrap(desk.inventory.pendingRequests.first { $0.itemID == itemID }).id, approve: approve)
        }

        Given("the administrator approves the request for {string}") { match, _ in
            try decide(match, approve: true)
        }

        When("the administrator approves the request for {string}") { match, _ in
            try decide(match, approve: true)
        }

        When("the administrator rejects the request for {string}") { match, _ in
            try decide(match, approve: false)
        }

        Then("I can choose from {string}") { match, _ in
            let offered = viewModel.categories
                .map { "\($0.name): " + $0.items.map(\.name).joined(separator: ", ") }
                .joined(separator: "; ")
            XCTAssertEqual(offered, try match.first(\.string))
        }

        Then("the supply request screen says {string}") { match, _ in
            XCTAssertEqual(english(viewModel.message), try match.first(\.string))
        }

        Then("the administrator sees a request from {string} for {string} in the {string} zone marked {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let log = RequestLog(alerts: [], inventory: desk.inventory, staff: [me])
            let entry = try XCTUnwrap(log.openEntries.first)
            XCTAssertEqual(entry.workerName, texts[0])
            XCTAssertEqual(entry.details, texts[1])
            let request = try XCTUnwrap(desk.inventory.pendingRequests.first)
            XCTAssertEqual(request.zoneID, zone.id)
            XCTAssertEqual(texts[2], zone.name)
            XCTAssertEqual(request.urgency, urgency(texts[3]))
            XCTAssertEqual(entry.isUrgent, texts[3] == "out of stock")
        }

        Then("the administrator has no supply requests") { _, _ in
            XCTAssertTrue(desk.inventory.requests.isEmpty)
        }

        Then("my requests are:") { _, step in
            viewModel.refresh()
            let expected = (step.dataTable?.rows.dropFirst() ?? []).map { $0.joined(separator: " | ") }
            let actual = viewModel.myRequests.map { [$0.itemName, $0.amount, $0.status.displayName].joined(separator: " | ") }
            XCTAssertEqual(actual, Array(expected))
        }
    }
}
