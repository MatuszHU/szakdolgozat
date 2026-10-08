import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    @K5
    func setupScheduleSteps() {
        var venue = Venue(name: "Club Neon")
        var people: [WorkerUser] = []
        var me: WorkerUser!
        var shifts: [Shift] = []
        var clock = Date()
        var viewModel: ScheduleViewModel!

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        func date(_ text: String) throws -> Date {
            try XCTUnwrap(formatter.date(from: text), "Bad date in scenario: \(text)")
        }

        func text(_ date: Date, _ format: String) -> String {
            formatter.dateFormat = format
            defer { formatter.dateFormat = "yyyy-MM-dd HH:mm" }
            return formatter.string(from: date)
        }

        func person(named name: String) throws -> WorkerUser {
            try XCTUnwrap(people.first { $0.name == name }, "Unknown person in scenario: \(name)")
        }

        func zoneID(named name: String) throws -> UUID? {
            guard !name.isEmpty else { return nil }
            return try XCTUnwrap(venue.floors.flatMap(\.zones).first { $0.name == name }, "Unknown zone: \(name)").id
        }

        func places(_ entries: [WorkerSchedule.Entry]) -> String {
            entries.map { $0.place ?? "no zone" }.joined(separator: ", ")
        }

        BeforeScenario { _ in
            venue = Venue(name: "Club Neon")
            people = []
            me = nil
            shifts = []
            clock = Date()
            viewModel = nil
        }

        Given("the schedule venue has the floor {string} at level {int} with the zones {string} and {string}") { match, _ in
            let names = try match.allParameters(\.string)
            let floor = try venue.addFloor(named: names[0], level: try match.first(\.int), width: 10, height: 8)
            try venue.editFloor(id: floor.id) {
                try $0.addZone(named: names[1], outline: [PlanPoint(x: 0, y: 0), PlanPoint(x: 1, y: 0), PlanPoint(x: 1, y: 1)])
                try $0.addZone(named: names[2], outline: [PlanPoint(x: 2, y: 2), PlanPoint(x: 3, y: 2), PlanPoint(x: 3, y: 3)])
            }
        }

        Given("I am {string} on the schedule and my colleague is {string}") { match, _ in
            people = try match.allParameters(\.string).map {
                WorkerUser(appleID: $0, name: $0, role: .bartender, payPeriod: .weekly)
            }
            me = people[0]
        }

        Given("the time is {string}") { match, _ in
            clock = try date(try match.first(\.string))
        }

        Given("the shift plan has:") { _, step in
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                let workers = try row[0].split(separator: ",").map {
                    try person(named: $0.trimmingCharacters(in: .whitespaces)).id
                }
                shifts.append(Shift(workerIDs: workers, capacity: workers.count,
                                    startTime: try date(row[1]), endTime: try date(row[2]),
                                    zoneID: try zoneID(named: row[3].trimmingCharacters(in: .whitespaces))))
            }
        }

        Given("the shift at {string} has the tasks:") { match, step in
            let zone = try zoneID(named: try match.first(\.string))
            let index = try XCTUnwrap(shifts.firstIndex { $0.zoneID == zone })
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                shifts[index].tasks.append(ShiftTask(title: row[0], description: "",
                                                     assignedWorkerIDs: [try person(named: row[1]).id], workstation: ""))
            }
        }

        When("I open my schedule") { _, _ in
            let now = clock
            viewModel = ScheduleViewModel(workerID: me.id, shifts: shifts, venue: venue, now: { now })
        }

        Then("my upcoming shifts are:") { _, step in
            let expected = (step.dataTable?.rows.dropFirst() ?? []).map { $0.joined(separator: " | ") }
            let actual = viewModel.days.flatMap { day in
                day.entries.map { entry in
                    [text(day.date, "yyyy-MM-dd"),
                     text(entry.shift.startTime, "HH:mm") + "–" + text(entry.shift.endTime, "HH:mm"),
                     entry.place ?? "no zone"].joined(separator: " | ")
                }
            }
            XCTAssertEqual(actual, Array(expected))
        }

        Then("my shift at {string} shows the tasks {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let entry = try XCTUnwrap(viewModel.schedule.entries.first { $0.zoneName == texts[0] })
            XCTAssertEqual(entry.tasks.map(\.title).joined(separator: ", "), texts[1])
        }

        Then("my current shift is at {string}") { match, _ in
            XCTAssertEqual(viewModel.schedule.current?.place, try match.first(\.string))
        }

        Then("my next shift is at {string}") { match, _ in
            XCTAssertEqual(viewModel.schedule.next?.place, try match.first(\.string))
        }

        Then("my finished shifts are at {string}") { match, _ in
            XCTAssertEqual(places(viewModel.schedule.past), try match.first(\.string))
        }

        Then("I have no upcoming shifts") { _, _ in
            XCTAssertTrue(viewModel.hasNoUpcomingShifts)
            XCTAssertTrue(viewModel.days.isEmpty)
        }
    }
}
