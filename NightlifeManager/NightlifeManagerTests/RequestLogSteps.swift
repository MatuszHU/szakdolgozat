import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

extension Cucumber {

    @L8 @K8 @K17
    func setupRequestLogSteps(inventory: @escaping () -> InventoryViewModel) {
        let evening = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 10))!
        var staff: [WorkerUser] = []
        var alerts: [PanicAlert] = []
        var requestIDs: [String: UUID] = [:]
        var viewModel: RequestLogViewModel!

        func time(_ hour: Int, _ minute: Int) -> Date {
            Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: evening)!
        }

        func worker(_ name: String) throws -> WorkerUser {
            try XCTUnwrap(staff.first { $0.name == name }, "Unknown worker: \(name)")
        }

        BeforeScenario { _ in
            staff = []
            alerts = []
            requestIDs = [:]
            viewModel = nil
        }

        Given("the workers {string} and {string} are on the staff") { match, _ in
            staff = try match.allParameters(\.string).map { WorkerUser(appleID: $0, name: $0, role: .bartender, payPeriod: .weekly) }
        }

        Given("{string} requested {int} of {string} at {int}:{int}") { match, _ in
            let texts = try match.allParameters(\.string)
            let numbers = try match.allParameters(\.int)
            let item = try XCTUnwrap(inventory().inventory.items.first { $0.name == texts[1] })
            let id = try XCTUnwrap(inventory().receiveRequest(from: try worker(texts[0]).id, itemID: item.id,
                                                              quantity: Double(numbers[0]), at: time(numbers[1], numbers[2])))
            requestIDs[texts[0]] = id
        }

        Given("the request of {string} was approved") { match, _ in
            inventory().approveRequest(id: try XCTUnwrap(requestIDs[try match.first(\.string)]))
            XCTAssertNil(inventory().errorMessage)
        }

        Given("{string} raised a panic alert at {int}:{int}") { match, _ in
            let numbers = try match.allParameters(\.int)
            alerts.append(PanicAlert(workerID: try worker(try match.first(\.string)).id, timestamp: time(numbers[0], numbers[1])))
        }

        Given("the panic alert of {string} was acknowledged by {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let index = try XCTUnwrap(alerts.firstIndex { $0.workerID == (try? worker(texts[0]).id) })
            XCTAssertTrue(alerts[index].acknowledge(by: try worker(texts[1]).id))
        }

        When("the administrator opens the request log") { _, _ in
            viewModel = RequestLogViewModel(alerts: alerts, inventory: inventory().inventory, staff: staff)
        }

        When("the administrator shows only open requests") { _, _ in
            viewModel.showsOnlyOpen = true
        }

        Then("the log lists:") { _, step in
            let expected = Array(step.dataTable?.rows.dropFirst() ?? [])
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let actual = viewModel.entries.map { entry in
                [formatter.string(from: entry.date),
                 entry.category.displayName, entry.workerName, entry.details, entry.isOpen ? "open" : "closed"]
            }
            XCTAssertEqual(actual, expected)
        }

        Then("the categories are {string}") { match, _ in
            let counts = RequestLog.Category.allCases.map { "\($0.displayName): \(viewModel.count(of: $0))" }
            XCTAssertEqual(counts.joined(separator: ", "), try match.first(\.string))
        }
    }
}
