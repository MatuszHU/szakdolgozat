//
//  ShiftPlanningSteps.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

/// Keeps the saved plan in memory instead of a file.
final class InMemoryShiftPlanStore: ShiftPlanStoring {
    private(set) var saved: ShiftPlan?

    func load() -> ShiftPlan? { saved }

    func save(_ plan: ShiftPlan) throws {
        saved = plan
    }
}

extension Cucumber {

    func setupShiftPlanningSteps() {
        let evening = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 10))!
        var zones: [Zone] = []
        var viewModel: ShiftPlannerViewModel!

        /// Night-time clock: hours before noon belong to the next day.
        func time(_ hour: Int, _ minute: Int) -> Date {
            let day = hour < 12 ? Calendar.current.date(byAdding: .day, value: 1, to: evening)! : evening
            return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }

        func zone(named name: String) -> Zone {
            guard let zone = zones.first(where: { $0.name == name }) else {
                XCTFail("Unknown zone in scenario: \(name)")
                return Zone(name: name)
            }
            return zone
        }

        func worker(named name: String) -> WorkerUser {
            guard let worker = viewModel.plan.staff.first(where: { $0.name == name }) else {
                XCTFail("Unknown worker in scenario: \(name)")
                return WorkerUser(appleID: name, name: name, role: .bartender, payPeriod: .weekly)
            }
            return worker
        }

        func shift(inZone name: String) -> Shift? {
            let zoneID = zone(named: name).id
            return viewModel.plan.shifts.first { $0.zoneID == zoneID }
        }

        func role(_ text: String) -> WorkerRole {
            switch text {
            case "bartender": return .bartender
            case "security": return .security
            default: return .custom(text)
            }
        }

        func createShift(_ match: Match) throws {
            let t = try match.allParameters(\.int)
            viewModel.createShift(from: time(t[0], t[1]), to: time(t[2], t[3]),
                                  zoneID: zone(named: try match.first(\.string)).id, capacity: t[4])
        }

        func assign(_ match: Match) throws {
            let names = try match.allParameters(\.string)
            let shiftID = try XCTUnwrap(shift(inZone: names[1])?.id)
            viewModel.assign(workerID: worker(named: names[0]).id, toShift: shiftID)
        }

        func giveTask(_ match: Match) throws {
            let texts = try match.allParameters(\.string)
            let shiftID = try XCTUnwrap(shift(inZone: texts[2])?.id)
            viewModel.addTask(titled: texts[1], toShift: shiftID, for: worker(named: texts[0]).id)
        }

        func workerShift(_ match: Match) throws -> (WorkerUser, Shift?) {
            let t = try match.allParameters(\.int)
            let person = worker(named: try match.first(\.string))
            let created = viewModel.createShift(from: time(t[0], t[1]), to: time(t[2], t[3]), zoneID: nil, capacity: 1)
            return (person, created)
        }

        BeforeScenario { _ in
            zones = []
            viewModel = ShiftPlannerViewModel(plan: ShiftPlan(), store: InMemoryShiftPlanStore())
        }

        Given("the planning venue has the zones {string} and {string}") { match, _ in
            zones = try match.allParameters(\.string).map { Zone(name: $0) }
        }

        Given("the staff are {string}, {string} and {string}") { match, _ in
            for name in try match.allParameters(\.string) {
                viewModel.addWorker(named: name, role: .bartender)
            }
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("{string} works a shift from {int}:{int} to {int}:{int}") { match, _ in
            let (person, created) = try workerShift(match)
            viewModel.assign(workerID: person.id, toShift: try XCTUnwrap(created?.id))
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("there is a shift in the {string} zone from {int}:{int} to {int}:{int} for {int} worker(s)") { match, _ in
            try createShift(match)
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("{string} is on the {string} shift") { match, _ in
            try assign(match)
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("the administrator gave {string} the task {string} on the {string} shift") { match, _ in
            try giveTask(match)
            XCTAssertNil(viewModel.errorMessage)
        }

        When("{string} is assigned a shift from {int}:{int} to {int}:{int}") { match, _ in
            let (person, created) = try workerShift(match)
            viewModel.assign(workerID: person.id, toShift: try XCTUnwrap(created?.id))
        }

        When("the administrator adds the worker {string} as {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            viewModel.addWorker(named: texts[0], role: role(texts[1]))
        }

        When("the administrator creates a shift in the {string} zone from {int}:{int} to {int}:{int} for {int} worker(s)") { match, _ in
            try createShift(match)
        }

        When("the administrator assigns {string} to the {string} shift") { match, _ in
            try assign(match)
        }

        When("the administrator gives {string} the task {string} on the {string} shift") { match, _ in
            try giveTask(match)
        }

        When("the administrator removes {string} from the {string} shift") { match, _ in
            let names = try match.allParameters(\.string)
            viewModel.unassign(workerID: worker(named: names[0]).id, fromShift: try XCTUnwrap(shift(inZone: names[1])?.id))
        }

        Then("the planner shows {string}") { match, _ in
            XCTAssertEqual(viewModel.errorMessage, try match.first(\.string))
        }

        Then("the planner shows no error") { _, _ in
            XCTAssertNil(viewModel.errorMessage)
        }

        Then("{string} works {int} shift(s)") { match, _ in
            XCTAssertEqual(viewModel.plan.shifts(for: worker(named: try match.first(\.string)).id).count,
                           try match.first(\.int))
        }

        Then("the staff are listed as {string}") { match, _ in
            XCTAssertEqual(viewModel.plan.staff.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the {string} shift lasts from {int}:{int} to {int}:{int} and has {int} free places") { match, _ in
            let t = try match.allParameters(\.int)
            let found = try XCTUnwrap(shift(inZone: try match.first(\.string)))
            XCTAssertEqual(found.startTime, time(t[0], t[1]))
            XCTAssertEqual(found.endTime, time(t[2], t[3]))
            XCTAssertEqual(found.freePlaces, t[4])
        }

        Then("the {string} shift has {int} free place(s)") { match, _ in
            XCTAssertEqual(shift(inZone: try match.first(\.string))?.freePlaces, try match.first(\.int))
        }

        Then("the {string} shift has the workers {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let ids = shift(inZone: texts[0])?.workerIDs ?? []
            let names = viewModel.plan.staff.filter { ids.contains($0.id) }.map(\.name).joined(separator: ", ")
            XCTAssertEqual(names, texts[1])
        }

        Then("{string} has the task {string} on the {string} shift") { match, _ in
            let texts = try match.allParameters(\.string)
            let task = shift(inZone: texts[2])?.tasks.first { $0.title == texts[1] }
            XCTAssertEqual(task?.assignedWorkerIDs, [worker(named: texts[0]).id])
        }

        Then("{string} has no task on the {string} shift") { match, _ in
            let texts = try match.allParameters(\.string)
            let id = worker(named: texts[0]).id
            XCTAssertEqual(shift(inZone: texts[1])?.tasks.filter { $0.assignedWorkerIDs.contains(id) }.count, 0)
        }
    }
}
