import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

extension Cucumber {

    @L4
    func setupStaffMapSteps() {
        let tonight = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 10, hour: 18))!
        let now = tonight.addingTimeInterval(4 * 3600)
        var venue = Venue(name: "Club Neon")
        var staff: [WorkerUser] = []
        var shifts: [Shift] = []
        var checkIns: [ZoneCheckIn] = []
        var viewModel: StaffMapViewModel!

        func zone(named name: String) -> Zone {
            guard let zone = venue.floors.flatMap(\.zones).first(where: { $0.name == name }) else {
                XCTFail("Unknown zone in scenario: \(name)")
                return Zone(name: name)
            }
            return zone
        }

        func worker(named name: String) -> WorkerUser {
            guard let worker = staff.first(where: { $0.name == name }) else {
                XCTFail("Unknown worker in scenario: \(name)")
                return WorkerUser(appleID: name, name: name, role: .bartender, payPeriod: .weekly)
            }
            return worker
        }

        BeforeScenario { _ in
            venue = Venue(name: "Club Neon")
            staff = []
            shifts = []
            checkIns = []
            viewModel = nil
        }

        Given("the staff map venue has the floor {string} at level {int} with the zones {string} and {string}") { match, _ in
            let names = try match.allParameters(\.string)
            let floor = try venue.addFloor(named: names[0], level: try match.first(\.int), width: 10, height: 8)
            try venue.editFloor(id: floor.id) {
                try $0.addZone(named: names[1], cells: [GridCell(row: 0, column: 0)])
                try $0.addZone(named: names[2], cells: [GridCell(row: 1, column: 1)])
            }
        }

        Given("tonight's shifts are:") { _, step in
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                let member = WorkerUser(appleID: row[0], name: row[0], role: .bartender, payPeriod: .weekly)
                staff.append(member)
                let task = Task(title: row[2], description: "", assignedWorkerIDs: [member.id], workstation: row[1])
                var shift = Shift(startTime: tonight, endTime: tonight.addingTimeInterval(10 * 3600),
                                  zoneID: zone(named: row[1]).id, tasks: [task])
                _ = shift.assign(workerID: member.id)
                shifts.append(shift)
            }
        }

        Given("{string} checked in to the {string} zone at {int}:{int}") { match, _ in
            let names = try match.allParameters(\.string)
            let time = try match.allParameters(\.int)
            let timestamp = Calendar.current.date(bySettingHour: time[0], minute: time[1], second: 0, of: tonight)!
            checkIns.append(ZoneCheckIn(workerID: worker(named: names[0]).id, zoneID: zone(named: names[1]).id,
                                        timestamp: timestamp))
        }

        When("the administrator opens the staff map") { _, _ in
            viewModel = StaffMapViewModel(venue: venue, staff: staff, checkIns: checkIns, shifts: shifts, now: now)
        }

        When("the administrator selects {string}") { match, _ in
            viewModel.selectWorker(id: worker(named: try match.first(\.string)).id)
        }

        When("the administrator switches to the floor {string}") { match, _ in
            let name = try match.first(\.string)
            viewModel.selectFloor(id: try XCTUnwrap(venue.floors.first { $0.name == name }?.id))
        }

        Then("the {string} zone shows {string}") { match, _ in
            let names = try match.allParameters(\.string)
            XCTAssertEqual(viewModel.names(inZone: zone(named: names[0]).id), [names[1]])
        }

        Then("the {string} zone shows nobody") { match, _ in
            XCTAssertEqual(viewModel.names(inZone: zone(named: try match.first(\.string)).id), [])
        }

        Then("the details show the work area {string}, the position {string} and the task {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let details = try XCTUnwrap(viewModel.selectedDetails)
            XCTAssertEqual(details.workAreaName, texts[0])
            XCTAssertEqual(details.positionName, texts[1])
            XCTAssertEqual(details.taskTitles, [texts[2]])
        }

        Then("{string} are listed as not checked in") { match, _ in
            XCTAssertEqual(viewModel.staffWithoutPosition.map(\.name).joined(separator: ", "), try match.first(\.string))
        }
    }
}
