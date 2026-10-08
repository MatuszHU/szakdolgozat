//
//  EventManagementSteps.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

/// Keeps the saved event catalog in memory instead of a file.
final class InMemoryEventCatalogStore: EventCatalogStoring {
    private(set) var saved: EventCatalog?

    func load() -> EventCatalog? { saved }

    func save(_ catalog: EventCatalog) throws {
        saved = catalog
    }
}

extension Cucumber {

    func setupEventManagementSteps() {
        var viewModel: EventManagerViewModel!

        /// October `day` of 2026 at the given time; hours before noon belong to the next day.
        func time(day: Int, _ hour: Int, _ minute: Int) -> Date {
            let date = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: day))!
            let shifted = hour < 12 ? Calendar.current.date(byAdding: .day, value: 1, to: date)! : date
            return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: shifted)!
        }

        func event(named title: String) throws -> Event {
            try XCTUnwrap(viewModel.catalog.events.first { $0.title == title }, "Unknown event: \(title)")
        }

        func ticketType(_ name: String) -> TicketType {
            switch name {
            case "Standard": return .standard
            case "VIP": return .vip
            default: return .custom(name)
            }
        }

        func offer(_ match: Match, quota: Int?) throws {
            let texts = try match.allParameters(\.string)
            viewModel.offerTickets(ticketType(texts[0]), price: Double(try match.first(\.int)), quota: quota,
                                   forEvent: try event(named: texts[1]).id)
        }

        BeforeScenario { _ in
            viewModel = EventManagerViewModel(catalog: EventCatalog(), store: InMemoryEventCatalogStore())
        }

        Given("the event {string} on October {int} for {int} guests") { match, _ in
            let numbers = try match.allParameters(\.int)
            viewModel.createEvent(titled: try match.first(\.string), location: "Club Neon",
                                  from: time(day: numbers[0], 22, 0), to: time(day: numbers[0], 4, 0),
                                  capacity: numbers[1])
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("{string} tickets are offered for {string} at {int} Ft") { match, _ in
            try offer(match, quota: nil)
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("{string} tickets are offered for {string} at {int} Ft limited to {int}") { match, _ in
            try offer(match, quota: try match.allParameters(\.int)[1])
            XCTAssertNil(viewModel.errorMessage)
        }

        When("the administrator creates the event {string} at {string} on October {int} from {int}:{int} to {int}:{int} for {int} guests") { match, _ in
            let texts = try match.allParameters(\.string)
            let n = try match.allParameters(\.int)
            viewModel.createEvent(titled: texts[0], location: texts[1],
                                  from: time(day: n[0], n[1], n[2]), to: time(day: n[0], n[3], n[4]), capacity: n[5])
        }

        When("the administrator offers {string} tickets for {string} at {int} Ft") { match, _ in
            try offer(match, quota: nil)
        }

        When("the administrator offers {string} tickets for {string} at {int} Ft limited to {int}") { match, _ in
            try offer(match, quota: try match.allParameters(\.int)[1])
        }

        When("the administrator announces the raffle {string} with the prize {string} for {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            viewModel.announceRaffle(titled: texts[0], prize: texts[1], forEvent: try event(named: texts[2]).id)
        }

        Then("the events are {string}") { match, _ in
            XCTAssertEqual(viewModel.catalog.events.map(\.title).joined(separator: ", "), try match.first(\.string))
        }

        Then("there are no events") { _, _ in
            XCTAssertTrue(viewModel.catalog.events.isEmpty)
        }

        Then("{string} lasts from {int}:{int} to {int}:{int} at {string} with {int} places") { match, _ in
            let texts = try match.allParameters(\.string)
            let n = try match.allParameters(\.int)
            let found = try event(named: texts[0])
            let day = Calendar.current.component(.day, from: found.startTime)
            XCTAssertEqual(found.startTime, time(day: day, n[0], n[1]))
            XCTAssertEqual(found.endTime, time(day: day, n[2], n[3]))
            XCTAssertEqual(found.location, texts[1])
            XCTAssertEqual(found.capacity, n[4])
        }

        Then("{string} offers {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let summary = try event(named: texts[0]).ticketOffers.map { offer in
                "\(offer.type.displayName) for \(Int(offer.price)) Ft" + (offer.quota.map { " (\($0) places)" } ?? "")
            }
            XCTAssertEqual(summary.joined(separator: ", "), texts[1])
        }

        Then("{string} has the raffle {string} with the prize {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let raffle = try event(named: texts[0]).raffle
            XCTAssertEqual(raffle?.title, texts[1])
            XCTAssertEqual(raffle?.prize, texts[2])
        }

        Then("the event manager shows {string}") { match, _ in
            XCTAssertEqual(viewModel.errorMessage, try match.first(\.string))
        }
    }
}
