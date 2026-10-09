import Foundation
import Testing
import SharedKit
@testable import Nightlife

@Suite("TicketShopViewModel")
@M4
struct TicketShopViewModelTests {

    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func catalog() throws -> (EventCatalog, Event) {
        var catalog = EventCatalog()
        let event = try catalog.createEvent(titled: "Friday Night", location: "", from: now.addingTimeInterval(86_400),
                                            to: now.addingTimeInterval(108_000), capacity: 10)
        try catalog.offerTickets(.standard, price: 3000, quota: nil, forEvent: event.id)
        return (catalog, event)
    }

    @Test func unavailablePaymentIssuesNoTicket() throws {
        let (catalog, event) = try catalog()
        let viewModel = TicketShopViewModel(catalog: catalog, guestID: UUID(), payment: UnavailablePaymentProcessor(), now: now)
        viewModel.buy(.standard, quantity: 1, forEvent: event.id)
        #expect(english(viewModel.errorMessage) == "Payment is not available yet")
        #expect(viewModel.myTickets.isEmpty)
    }

    @Test func testPaymentApprovesInDebugBuilds() throws {
        let (catalog, event) = try catalog()
        let viewModel = TicketShopViewModel(catalog: catalog, guestID: UUID(), payment: TestPaymentProcessor(), now: now)
        viewModel.buy(.standard, quantity: 1, forEvent: event.id)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.myTickets.count == 1)
    }

    @Test func onlyEventsThatAreNotOverAreForSale() throws {
        var (catalog, _) = try catalog()
        try catalog.createEvent(titled: "Last Week", location: "", from: now.addingTimeInterval(-7 * 86_400),
                                to: now.addingTimeInterval(-7 * 86_400 + 3600), capacity: 10)
        let viewModel = TicketShopViewModel(catalog: catalog, guestID: UUID(), payment: TestPaymentProcessor(), now: now)
        #expect(viewModel.eventsOnSale.map(\.title) == ["Friday Night"])
    }
}
