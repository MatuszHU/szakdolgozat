import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

@K8
final class RecordingPanicAlertSender: PanicAlertSending {
    private(set) var sent: [(alert: PanicAlert, message: String, recipientIDs: [UUID])] = []

    func send(_ alert: PanicAlert, message: String, to recipientIDs: [UUID]) {
        sent.append((alert, message, recipientIDs))
    }
}

extension Cucumber {

    @K8
    func setupPanicModeSteps() {
        var staff: [String: WorkerUser] = [:]
        var positions: [String: WorkerPosition] = [:]
        var sender = RecordingPanicAlertSender()
        var alert: PanicAlert?

        func worker(_ name: String) -> WorkerUser {
            guard let worker = staff[name] else {
                XCTFail("Unknown staff member in scenario: \(name)")
                return WorkerUser(appleID: name, name: name, role: .custom("unknown"), payPeriod: .weekly)
            }
            return worker
        }

        func role(_ text: String) -> WorkerRole {
            switch text {
            case "bartender": return .bartender
            case "security": return .security
            default: return .custom(text)
            }
        }

        func checkIn(_ name: String, zoneName: String) throws {
            try positions[name]?.checkIn(scanning: World.zone(named: zoneName).qrPayload,
                                         knownZoneIDs: Set(World.zones.map(\.id)))
        }

        func activatePanic(_ name: String) {
            let viewModel = PanicViewModel(worker: worker(name),
                                           colleagues: Array(staff.values),
                                           zones: World.zones,
                                           sender: sender)
            viewModel.activate(currentZoneID: positions[name]?.currentZoneID)
            alert = viewModel.activeAlert
        }

        func acknowledge(_ name: String) {
            guard let current = alert else { return XCTFail("No panic alert in scenario") }
            let inbox = PanicInboxViewModel(user: worker(name))
            inbox.receive(current)
            if let updated = inbox.acknowledge(alertID: current.id) {
                alert = updated
            }
        }

        func lastRecipientNames() -> Set<String> {
            let ids = Set(sender.sent.last?.recipientIDs ?? [])
            return Set(staff.filter { ids.contains($0.value.id) }.map(\.key))
        }

        Given("the staff on shift:") { _, step in
            staff = [:]
            positions = [:]
            sender = RecordingPanicAlertSender()
            alert = nil
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                let member = WorkerUser(appleID: row[0], name: row[0], role: role(row[1]), payPeriod: .weekly)
                staff[row[0]] = member
                positions[row[0]] = WorkerPosition(workerID: member.id, isOnShift: true)
            }
        }

        Given("{string} is checked in to the {string} zone") { match, _ in
            let names = try match.allParameters(\.string)
            try checkIn(names[0], zoneName: names[1])
            XCTAssertEqual(positions[names[0]]?.currentZoneID, World.zone(named: names[1]).id)
        }

        Given("{string} has not checked in to any zone") { match, _ in
            XCTAssertNil(positions[try match.first(\.string)]?.currentZoneID)
        }

        Given("{string} activated panic mode in the {string} zone") { match, _ in
            let names = try match.allParameters(\.string)
            try checkIn(names[0], zoneName: names[1])
            activatePanic(names[0])
        }

        Given("{string} acknowledged the alert") { match, _ in
            acknowledge(try match.first(\.string))
        }

        When("{string} activates panic mode") { match, _ in
            activatePanic(try match.first(\.string))
        }

        When("{string} acknowledges the alert") { match, _ in
            acknowledge(try match.first(\.string))
        }

        Then("a panic alert is sent to {string} and {string}") { match, _ in
            XCTAssertEqual(lastRecipientNames(), Set(try match.allParameters(\.string)))
        }

        Then("a panic alert is sent only to {string}") { match, _ in
            XCTAssertEqual(lastRecipientNames(), [try match.first(\.string)])
        }

        Then("the alert says {string}") { match, _ in
            XCTAssertEqual(sender.sent.last?.message, try match.first(\.string))
        }

        Then("the alert is acknowledged by {string}") { match, _ in
            XCTAssertEqual(alert?.isAcknowledged, true)
            XCTAssertEqual(alert?.acknowledgedByID, worker(try match.first(\.string)).id)
        }
    }
}
