import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    @K13
    func setupNotificationSteps() {
        var sources = NotificationSources(workerID: UUID())
        var day = "2026-10-09"
        var clock = Date()
        var viewModel: NotificationsViewModel!

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        func at(_ time: String) throws -> Date {
            try XCTUnwrap(formatter.date(from: "\(day) \(time)"), "Bad time in scenario: \(time)")
        }

        func role(_ name: String) -> WorkerRole {
            name == "security" ? .security : name == "bartender" ? .bartender : .custom(name)
        }

        func person(named name: String) throws -> WorkerUser {
            try XCTUnwrap(sources.staff.first { $0.name == name }, "Unknown person in scenario: \(name)")
        }

        func zoneID(named name: String) throws -> UUID {
            try XCTUnwrap(sources.venue.floors.flatMap(\.zones).first { $0.name == name }, "Unknown zone: \(name)").id
        }

        func arrive(at time: String) throws {
            clock = try at(time)
            viewModel.open()
        }

        func kind(_ name: String) -> NotificationKind? {
            NotificationKind(rawValue: name)
        }

        BeforeScenario { _ in
            sources = NotificationSources(workerID: UUID())
            day = "2026-10-09"
            clock = Date()
            viewModel = NotificationsViewModel(sources: { sources }, now: { clock })
        }

        Given("the notification venue has the floor {string} with the zone {string}") { match, _ in
            let names = try match.allParameters(\.string)
            let floor = try sources.venue.addFloor(named: names[0], level: 0, width: 10, height: 10)
            try sources.venue.editFloor(id: floor.id) {
                try $0.addZone(named: names[1], outline: [PlanPoint(x: 0, y: 0), PlanPoint(x: 1, y: 0), PlanPoint(x: 1, y: 1)])
            }
        }

        Given("I am {string} from {string} and my colleague is {string}, a {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let me = WorkerUser(appleID: texts[0], name: texts[0], role: role(texts[1]), payPeriod: .weekly)
            let colleague = WorkerUser(appleID: texts[2], name: texts[2], role: role(texts[3]), payPeriod: .weekly)
            sources.staff = [me, colleague]
            sources.workerID = me.id
        }

        Given("the day is {string}") { match, _ in
            day = try match.first(\.string)
        }

        Given("my role is {string}") { match, _ in
            let index = try XCTUnwrap(sources.staff.firstIndex { $0.id == sources.workerID })
            sources.staff[index].role = role(try match.first(\.string))
        }

        Given("at {string} I was assigned to a shift starting at {string} in the {string} zone") { match, _ in
            let texts = try match.allParameters(\.string)
            let start = try at(texts[1])
            sources.shifts.append(Shift(workerIDs: [sources.workerID], startTime: start,
                                        endTime: start.addingTimeInterval(6 * 3600), zoneID: try zoneID(named: texts[2])))
            try arrive(at: texts[0])
        }

        Given("at {string} my request for {string} was {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let parts = texts[1].split(separator: " ").map(String.init)
            let item = try sources.inventory.items.first { $0.name == parts[2] }
                ?? sources.inventory.addItem(named: parts[2], category: "Bar", quantity: 100, unit: parts[1], minimum: 0)
            let request = try sources.inventory.receiveRequest(from: sources.workerID, itemID: item.id,
                                                               quantity: try XCTUnwrap(Double(parts[0])), at: try at(texts[0]))
            switch texts[2] {
            case "approved": try sources.inventory.approveRequest(id: request.id)
            case "rejected": try sources.inventory.rejectRequest(id: request.id)
            default: break
            }
            try arrive(at: texts[0])
        }

        Given("at {string} {string} sent a panic alert from the {string} zone") { match, _ in
            let texts = try match.allParameters(\.string)
            sources.panicAlerts.append(PanicAlert(workerID: try person(named: texts[1]).id, timestamp: try at(texts[0]),
                                                  zoneID: try zoneID(named: texts[2])))
            try arrive(at: texts[0])
        }

        When("I open my notifications") { _, _ in
            viewModel.open()
        }

        When("I open my notifications again") { _, _ in
            viewModel.open()
        }

        When("I read the {string} notification") { match, _ in
            let title = try match.first(\.string)
            viewModel.markRead(id: try XCTUnwrap(viewModel.visible.first { $0.title == title }).id)
        }

        When("I mark all notifications as read") { _, _ in
            viewModel.markAllRead()
        }

        When("I show only the {string} notifications") { match, _ in
            viewModel.kindFilter = try XCTUnwrap(kind(try match.first(\.string)))
        }

        Then("my notifications are:") { _, step in
            let expected = (step.dataTable?.rows.dropFirst() ?? []).map { $0.joined(separator: " | ") }
            let actual = viewModel.visible.map { [$0.kind.rawValue, $0.title, $0.body].joined(separator: " | ") }
            XCTAssertEqual(actual, Array(expected))
        }

        Then("the number of unread notifications is {int}") { match, _ in
            XCTAssertEqual(viewModel.unreadCount, try match.first(\.int))
        }

        Then("I have no notifications") { _, _ in
            XCTAssertTrue(viewModel.visible.isEmpty)
        }
    }
}
