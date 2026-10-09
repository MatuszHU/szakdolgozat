import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    @K7 @M4
    func setupCodeReaderSteps() {
        var events: [String: Event] = [:]
        var tonight: Event!
        var repository = LocalTicketRepository()
        var viewModel: CodeReaderViewModel!

        func event(named title: String) -> Event {
            if let existing = events[title] { return existing }
            let created = Event(title: title, description: "", startTime: Date(), endTime: Date(),
                                location: "", capacity: 100)
            events[title] = created
            return created
        }

        func ticketType(_ text: String) -> TicketType {
            switch text {
            case "vip": return .vip
            case "standard": return .standard
            default: return .custom(text)
            }
        }

        Given("tonight's event is {string}") { match, _ in
            events = [:]
            repository = LocalTicketRepository()
            tonight = event(named: try match.first(\.string))
        }

        Given("the following tickets exist:") { _, step in
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                let guest = GuestUser(appleID: row[1], name: row[1])
                repository.guests.append(guest)
                repository.tickets.append(Ticket(eventID: event(named: row[2]).id, guestID: guest.id,
                                                 isUsed: row[4] == "yes", passTypeIdentifier: "",
                                                 serialNumber: row[0], price: 0,
                                                 ticketType: ticketType(row[3]), entrance: ""))
            }
        }

        Given("the code reader is open for a worker on shift") { _, _ in
            let zoneCheckIn = ZoneCheckInViewModel(workerID: UUID(), zones: World.zones, isOnShift: true)
            viewModel = CodeReaderViewModel(eventID: tonight.id, tickets: repository, zoneCheckIn: zoneCheckIn)
        }

        When("the code reader scans the ticket {string}") { match, _ in
            viewModel.handle(payload: Ticket.qrPrefix + (try match.first(\.string)))
        }

        When("the code reader scans the {string} zone code") { match, _ in
            viewModel.handle(payload: World.zone(named: try match.first(\.string)).qrPayload)
        }

        When("the code reader scans {string}") { match, _ in
            viewModel.handle(payload: try match.first(\.string))
        }

        Then("the code reader shows {string}") { match, _ in
            XCTAssertEqual(english(viewModel.message), try match.first(\.string))
        }

        Then("the ticket {string} is marked as used") { match, _ in
            XCTAssertEqual(repository.ticket(serialNumber: try match.first(\.string))?.isUsed, true)
        }

        Then("the ticket {string} is not marked as used") { match, _ in
            XCTAssertEqual(repository.ticket(serialNumber: try match.first(\.string))?.isUsed, false)
        }
    }
}
