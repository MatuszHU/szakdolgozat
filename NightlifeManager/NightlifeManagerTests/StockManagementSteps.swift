import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

@L10
final class InMemoryInventoryStore: InventoryStoring {
    private(set) var saved: Inventory?

    func load() -> Inventory? { saved }

    func save(_ inventory: Inventory) throws {
        saved = inventory
    }
}

extension Cucumber {

    @L10 @K17
    func setupStockManagementSteps() {
        var viewModel: InventoryViewModel!
        var requestID: UUID?

        func item(_ name: String) throws -> SupplyItem {
            try XCTUnwrap(viewModel.inventory.items.first { $0.name == name }, "Unknown item: \(name)")
        }

        BeforeScenario { _ in
            viewModel = InventoryViewModel(inventory: Inventory(), store: InMemoryInventoryStore())
            requestID = nil
        }

        Given("the stock has:") { _, step in
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                viewModel.addItem(named: row[0], category: row[1], quantity: Double(row[2])!, unit: row[3],
                                  minimum: Double(row[4])!)
            }
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("a worker requested {int} of {string}") { match, _ in
            let found = try item(try match.first(\.string))
            requestID = viewModel.receiveRequest(from: UUID(), itemID: found.id, quantity: Double(try match.first(\.int)))
            XCTAssertNotNil(requestID)
        }

        When("the administrator adds {string} in {string} with {int} {string} and a minimum of {int}") { match, _ in
            let texts = try match.allParameters(\.string)
            let numbers = try match.allParameters(\.int)
            viewModel.addItem(named: texts[0], category: texts[1], quantity: Double(numbers[0]), unit: texts[2],
                              minimum: Double(numbers[1]))
        }

        When("the quantity of {string} is set to {int}") { match, _ in
            viewModel.setQuantity(Double(try match.first(\.int)), ofItem: try item(try match.first(\.string)).id)
        }

        When("the administrator approves the request") { _, _ in
            viewModel.approveRequest(id: try XCTUnwrap(requestID))
        }

        When("the administrator rejects the request") { _, _ in
            viewModel.rejectRequest(id: try XCTUnwrap(requestID))
        }

        Then("the stock lists {string}") { match, _ in
            XCTAssertEqual(viewModel.inventory.items.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the stock screen shows {string}") { match, _ in
            XCTAssertEqual(viewModel.errorMessage, try match.first(\.string))
        }

        Then("the low stock items are {string}") { match, _ in
            XCTAssertEqual(viewModel.inventory.lowStockItems.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the administrator is warned that {string} is running low") { match, _ in
            XCTAssertEqual(viewModel.lowStockWarning, "\(try match.first(\.string)) is running low")
        }

        Then("the stock of {string} is {int}") { match, _ in
            XCTAssertEqual(try item(try match.first(\.string)).quantity, Double(try match.first(\.int)))
        }

        Then("the request is {string}") { match, _ in
            let status = try XCTUnwrap(viewModel.inventory.requests.first { $0.id == requestID }?.status)
            XCTAssertEqual(status.displayName, try match.first(\.string))
        }
    }
}
