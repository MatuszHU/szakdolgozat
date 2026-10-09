import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

@M4
final class RecordingPayment: PaymentProcessing {
    var approves = true
    private(set) var charges: [Double] = []

    func charge(_ amount: Double) -> Bool {
        guard approves else { return false }
        charges.append(amount)
        return true
    }
}

extension Cucumber {

    @M4 @K7
    func setupTicketPurchaseSteps() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let guestID = UUID()
        var catalog = EventCatalog()
        var payment = RecordingPayment()
        var viewModel: TicketShopViewModel?

        func shop() -> TicketShopViewModel {
            if let viewModel { return viewModel }
            let created = TicketShopViewModel(catalog: catalog, guestID: guestID, payment: payment, now: now)
            viewModel = created
            return created
        }

        func event(named title: String) throws -> Event {
            let events = viewModel?.catalog.events ?? catalog.events
            return try XCTUnwrap(events.first { $0.title == title }, "Unknown event: \(title)")
        }

        func ticketType(_ name: String) -> TicketType {
            switch name {
            case "Standard": return .standard
            case "VIP": return .vip
            default: return .custom(name)
            }
        }

        func createEvent(_ match: Match, step: Step, startOffsetDays: Int) throws {
            let numbers = try match.allParameters(\.int)
            let start = now.addingTimeInterval(Double(startOffsetDays) * 86_400)
            let created = try catalog.createEvent(titled: try match.first(\.string), location: "Club Neon",
                                                  from: start, to: start.addingTimeInterval(6 * 3600),
                                                  capacity: numbers[1])
            for row in step.dataTable?.rows.dropFirst() ?? [] {
                try catalog.offerTickets(ticketType(row[0]), price: Double(row[1])!,
                                         quota: Int(row[2]), forEvent: created.id)
            }
        }

        func myTickets(for title: String) -> [Ticket] {
            shop().myTickets.filter { $0.event.title == title }.map(\.ticket)
        }

        BeforeScenario { _ in
            catalog = EventCatalog()
            payment = RecordingPayment()
            viewModel = nil
        }

        Given("the guest is signed in for shopping") { _, _ in
            XCTAssertNil(viewModel)
        }

        Given("the event {string} starting in {int} day(s) for {int} guest(s) offers:") { match, step in
            try createEvent(match, step: step, startOffsetDays: try match.first(\.int))
        }

        Given("the event {string} starting {int} days ago for {int} guests offers:") { match, step in
            try createEvent(match, step: step, startOffsetDays: -(try match.first(\.int)))
        }

        Given("{int} {string} ticket(s) for {string} was/were sold to other guests") { match, _ in
            let texts = try match.allParameters(\.string)
            let found = try event(named: texts[1])
            try catalog.purchase(ticketType(texts[0]), quantity: try match.first(\.int), forEvent: found.id,
                                 guestID: UUID(), at: now)
        }

        Given("the payment will be declined") { _, _ in
            payment.approves = false
        }

        When("the guest buys {int} {string} ticket(s) for {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            shop().buy(ticketType(texts[0]), quantity: try match.first(\.int), forEvent: try event(named: texts[1]).id)
        }

        Then("the guest has {int} ticket(s) for {string}") { match, _ in
            XCTAssertEqual(myTickets(for: try match.first(\.string)).count, try match.first(\.int))
        }

        Then("{int} Ft is charged") { match, _ in
            XCTAssertEqual(payment.charges, [Double(try match.first(\.int))])
        }

        Then("nothing is charged") { _, _ in
            XCTAssertTrue(payment.charges.isEmpty)
        }

        Then("the shop shows {string}") { match, _ in
            XCTAssertEqual(english(shop().errorMessage), try match.first(\.string))
        }

        Then("the code reader recognises the guest's ticket for {string}") { match, _ in
            let ticket = try XCTUnwrap(myTickets(for: try match.first(\.string)).first)
            XCTAssertEqual(ScannedCode(payload: ticket.qrPayload), .ticket(serialNumber: ticket.serialNumber))
        }

        Then("the ticket is admitted to {string} once") { match, _ in
            let found = try event(named: try match.first(\.string))
            var ticket = try XCTUnwrap(myTickets(for: found.title).first)
            XCTAssertEqual(ticket.admit(toEvent: found.id), .admitted)
            XCTAssertEqual(ticket.admit(toEvent: found.id), .alreadyUsed)
        }

        Then("the guest's tickets are for {string}") { match, _ in
            XCTAssertEqual(shop().myTickets.map(\.event.title).joined(separator: ", "), try match.first(\.string))
        }
    }
}
