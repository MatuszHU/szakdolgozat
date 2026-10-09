import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

@M7
func english(_ resource: LocalizedStringResource?) -> String? {
    guard var resource else { return nil }
    resource.locale = Locale(identifier: "en")
    return String(localized: resource)
}

extension Cucumber {

    @M7
    func setupRaffleSteps() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let guestID = UUID()
        var catalog = EventCatalog()
        var viewModel: RaffleViewModel!

        func open() -> RaffleViewModel {
            if viewModel == nil {
                viewModel = RaffleViewModel(catalog: catalog, guestID: guestID, now: { now })
            }
            return viewModel
        }

        func event(named title: String) throws -> Event {
            try XCTUnwrap(open().catalog.events.first { $0.title == title }, "Unknown event: \(title)")
        }

        func register(_ match: Match) throws {
            open().register(forEvent: try event(named: try match.first(\.string)).id)
        }

        BeforeScenario { _ in
            catalog = EventCatalog()
            viewModel = nil
        }

        Given("the guest is signed in for the raffles") { _, _ in
            viewModel = nil
        }

        Given("the raffle events are:") { _, step in
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                let days = try XCTUnwrap(Double(row[1].trimmingCharacters(in: .whitespaces)))
                let start = now.addingTimeInterval(days * 86400)
                let event = try catalog.createEvent(titled: row[0], location: "Club Neon", from: start,
                                                    to: start.addingTimeInterval(6 * 3600), capacity: 100)
                if !row[2].isEmpty {
                    try catalog.announceRaffle(titled: row[2], prize: row[3], forEvent: event.id)
                }
            }
        }

        Given("the guest registered for the raffle of {string}") { match, _ in
            try register(match)
            XCTAssertFalse(viewModel.isError)
        }

        When("the guest opens the raffles") { _, _ in
            _ = open()
        }

        When("the guest registers for the raffle of {string}") { match, _ in
            try register(match)
        }

        Then("the raffles are {string}") { match, _ in
            let listed = viewModel.raffles.map { "\($0.event.title) – \($0.raffle.title)" }.joined(separator: ", ")
            XCTAssertEqual(listed, try match.first(\.string))
        }

        Then("the raffle of {string} offers {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            XCTAssertEqual(viewModel.raffles.first { $0.event.title == texts[0] }?.raffle.prize, texts[1])
        }

        Then("the guest is registered for the raffle of {string}") { match, _ in
            let title = try match.first(\.string)
            XCTAssertEqual(viewModel.raffles.first { $0.event.title == title }?.isEntered, true)
        }

        Then("the raffle of {string} has {int} participant(s)") { match, _ in
            let raffle = try XCTUnwrap(try event(named: try match.first(\.string)).raffle)
            XCTAssertEqual(raffle.participantIDs.count, try match.first(\.int))
        }

        Then("the raffle screen shows {string}") { match, _ in
            XCTAssertEqual(english(viewModel.message), try match.first(\.string))
        }
    }
}
