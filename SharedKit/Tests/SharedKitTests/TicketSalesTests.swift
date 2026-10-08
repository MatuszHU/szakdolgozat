import Foundation
import Testing
@testable import SharedKit

@Suite("Ticket sales")
@M4 @L11
struct TicketSalesTests {

    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let guest = UUID()

    private func catalog(capacity: Int = 100, startsIn days: Double = 2, vipQuota: Int? = 2) throws -> (EventCatalog, Event) {
        var catalog = EventCatalog()
        let start = now.addingTimeInterval(days * 86_400)
        let event = try catalog.createEvent(titled: "Friday Night", location: "", from: start,
                                            to: start.addingTimeInterval(6 * 3600), capacity: capacity)
        try catalog.offerTickets(.standard, price: 3000, quota: nil, forEvent: event.id)
        try catalog.offerTickets(.vip, price: 8000, quota: vipQuota, forEvent: event.id)
        return (catalog, event)
    }

    @Test func purchaseIssuesTicketsWithPriceAndUniqueSerials() throws {
        var (catalog, event) = try catalog()
        let tickets = try catalog.purchase(.vip, quantity: 2, forEvent: event.id, guestID: guest, at: now)
        #expect(tickets.count == 2)
        #expect(tickets.allSatisfy { $0.price == 8000 && $0.ticketType == .vip && $0.guestID == guest && !$0.isUsed })
        #expect(Set(tickets.map(\.serialNumber)).count == 2)
        #expect(catalog.events.first?.tickets.count == 2)
    }

    @Test func priceOfAPurchase() throws {
        let (catalog, event) = try catalog()
        #expect(try catalog.price(of: .vip, quantity: 3, forEvent: event.id) == 24000)
    }

    @Test func onlyOfferedTypesCanBeBought() throws {
        var (catalog, event) = try catalog()
        #expect(throws: EventCatalog.CatalogError.notOffered) {
            try catalog.purchase(.custom("Backstage"), quantity: 1, forEvent: event.id, guestID: guest, at: now)
        }
    }

    @Test func quotaCannotBeExceeded() throws {
        var (catalog, event) = try catalog(vipQuota: 2)
        try catalog.purchase(.vip, quantity: 1, forEvent: event.id, guestID: UUID(), at: now)
        #expect(throws: EventCatalog.CatalogError.soldOut(.vip)) {
            try catalog.purchase(.vip, quantity: 2, forEvent: event.id, guestID: guest, at: now)
        }
        try catalog.purchase(.vip, quantity: 1, forEvent: event.id, guestID: guest, at: now)
    }

    @Test func capacityCannotBeExceeded() throws {
        var (catalog, event) = try catalog(capacity: 3, vipQuota: nil)
        try catalog.purchase(.standard, quantity: 2, forEvent: event.id, guestID: UUID(), at: now)
        #expect(throws: EventCatalog.CatalogError.eventFull) {
            try catalog.purchase(.vip, quantity: 2, forEvent: event.id, guestID: guest, at: now)
        }
    }

    @Test func eventThatIsOverCannotBeBought() throws {
        var (catalog, event) = try catalog(startsIn: -7)
        #expect(throws: EventCatalog.CatalogError.eventOver) {
            try catalog.purchase(.standard, quantity: 1, forEvent: event.id, guestID: guest, at: now)
        }
    }

    @Test(arguments: [0, 11])
    func quantityMustBeBetweenOneAndTen(_ quantity: Int) throws {
        var (catalog, event) = try catalog()
        #expect(throws: EventCatalog.CatalogError.invalidQuantity) {
            try catalog.purchase(.standard, quantity: quantity, forEvent: event.id, guestID: guest, at: now)
        }
    }

    @Test func availabilityCheckDoesNotIssueTickets() throws {
        let (catalog, event) = try catalog()
        try catalog.checkAvailability(.standard, quantity: 1, forEvent: event.id, at: now)
        #expect(catalog.events.first?.tickets.isEmpty == true)
    }

    @Test func ticketsOfAGuestAreOrderedByEventStart() throws {
        var (catalog, later) = try catalog(startsIn: 5)
        let sooner = try catalog.createEvent(titled: "Opening Party", location: "", from: now.addingTimeInterval(86_400),
                                             to: now.addingTimeInterval(90_000), capacity: 10)
        try catalog.offerTickets(.standard, price: 1000, quota: nil, forEvent: sooner.id)
        try catalog.purchase(.standard, quantity: 1, forEvent: later.id, guestID: guest, at: now)
        try catalog.purchase(.standard, quantity: 1, forEvent: sooner.id, guestID: guest, at: now)
        try catalog.purchase(.standard, quantity: 1, forEvent: sooner.id, guestID: UUID(), at: now)
        #expect(catalog.tickets(of: guest).map(\.event.title) == ["Opening Party", "Friday Night"])
    }

    @Test func guestIDIsStablePerAppleAccount() {
        #expect(GuestUser.stableID(forAppleID: "apple-1") == GuestUser.stableID(forAppleID: "apple-1"))
        #expect(GuestUser.stableID(forAppleID: "apple-1") != GuestUser.stableID(forAppleID: "apple-2"))
    }
}
