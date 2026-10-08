import Foundation
import Testing
@testable import SharedKit

@Suite("EventCatalog")
@L11
struct EventCatalogTests {

    private let friday = Date(timeIntervalSince1970: 1_800_000_000)

    private func hours(_ value: Double, from base: Date? = nil) -> Date {
        (base ?? friday).addingTimeInterval(value * 3600)
    }

    private func catalogWithEvent(capacity: Int = 300) throws -> (EventCatalog, Event) {
        var catalog = EventCatalog()
        let event = try catalog.createEvent(titled: "Friday Night", location: "Club Neon",
                                            from: friday, to: hours(6), capacity: capacity)
        return (catalog, event)
    }

    @Test func createsAnEvent() throws {
        let (catalog, event) = try catalogWithEvent()
        #expect(catalog.events.map(\.id) == [event.id])
        #expect(event.title == "Friday Night")
        #expect(event.location == "Club Neon")
        #expect(event.capacity == 300)
        #expect(event.ticketOffers.isEmpty)
        #expect(event.raffle == nil)
    }

    @Test(arguments: ["", "  "])
    func eventNeedsATitle(_ title: String) {
        var catalog = EventCatalog()
        #expect(throws: EventCatalog.CatalogError.emptyTitle) {
            try catalog.createEvent(titled: title, location: "", from: friday, to: hours(1), capacity: 10)
        }
    }

    @Test func eventMustEndAfterItStarts() {
        var catalog = EventCatalog()
        #expect(throws: EventCatalog.CatalogError.invalidTime) {
            try catalog.createEvent(titled: "Friday Night", location: "", from: friday, to: friday, capacity: 10)
        }
    }

    @Test func eventNeedsAPlace() {
        var catalog = EventCatalog()
        #expect(throws: EventCatalog.CatalogError.invalidCapacity) {
            try catalog.createEvent(titled: "Friday Night", location: "", from: friday, to: hours(1), capacity: 0)
        }
    }

    @Test func eventsAreOrderedByStart() throws {
        var catalog = EventCatalog()
        try catalog.createEvent(titled: "Saturday Jam", location: "", from: hours(24), to: hours(30), capacity: 10)
        try catalog.createEvent(titled: "Friday Night", location: "", from: friday, to: hours(6), capacity: 10)
        #expect(catalog.events.map(\.title) == ["Friday Night", "Saturday Jam"])
    }

    @Test func offersTicketTypes() throws {
        var (catalog, event) = try catalogWithEvent()
        try catalog.offerTickets(.standard, price: 3000, quota: nil, forEvent: event.id)
        try catalog.offerTickets(.vip, price: 8000, quota: 50, forEvent: event.id)
        let offers = try #require(catalog.events.first?.ticketOffers)
        #expect(offers.map(\.type) == [.standard, .vip])
        #expect(offers.map(\.price) == [3000, 8000])
        #expect(offers.map(\.quota) == [nil, 50])
    }

    @Test func ticketTypeIsOfferedOnce() throws {
        var (catalog, event) = try catalogWithEvent()
        try catalog.offerTickets(.standard, price: 3000, quota: nil, forEvent: event.id)
        #expect(throws: EventCatalog.CatalogError.duplicateTicketType(.standard)) {
            try catalog.offerTickets(.standard, price: 2500, quota: nil, forEvent: event.id)
        }
        #expect(catalog.events.first?.ticketOffers.count == 1)
    }

    @Test func priceCannotBeNegative() throws {
        var (catalog, event) = try catalogWithEvent()
        #expect(throws: EventCatalog.CatalogError.negativePrice) {
            try catalog.offerTickets(.standard, price: -1, quota: nil, forEvent: event.id)
        }
    }

    @Test func freeTicketsAreAllowed() throws {
        var (catalog, event) = try catalogWithEvent()
        try catalog.offerTickets(.custom("Guest list"), price: 0, quota: nil, forEvent: event.id)
        #expect(catalog.events.first?.ticketOffers.first?.price == 0)
    }

    @Test func quotaMustBePositive() throws {
        var (catalog, event) = try catalogWithEvent()
        #expect(throws: EventCatalog.CatalogError.invalidQuota) {
            try catalog.offerTickets(.vip, price: 8000, quota: 0, forEvent: event.id)
        }
    }

    @Test func quotasCannotExceedCapacity() throws {
        var (catalog, event) = try catalogWithEvent(capacity: 300)
        try catalog.offerTickets(.vip, price: 8000, quota: 250, forEvent: event.id)
        #expect(throws: EventCatalog.CatalogError.quotaExceedsCapacity(300)) {
            try catalog.offerTickets(.custom("Backstage"), price: 15000, quota: 100, forEvent: event.id)
        }
        try catalog.offerTickets(.custom("Backstage"), price: 15000, quota: 50, forEvent: event.id)
        #expect(catalog.events.first?.ticketOffers.count == 2)
    }

    @Test func removesATicketOffer() throws {
        var (catalog, event) = try catalogWithEvent()
        try catalog.offerTickets(.standard, price: 3000, quota: nil, forEvent: event.id)
        let offerID = try #require(catalog.events.first?.ticketOffers.first?.id)
        try catalog.removeTicketOffer(id: offerID, fromEvent: event.id)
        #expect(catalog.events.first?.ticketOffers.isEmpty == true)
    }

    @Test func announcesAndRemovesARaffle() throws {
        var (catalog, event) = try catalogWithEvent()
        try catalog.announceRaffle(titled: "Win a bottle", prize: "Champagne", forEvent: event.id)
        #expect(catalog.events.first?.raffle?.title == "Win a bottle")
        #expect(catalog.events.first?.raffle?.prize == "Champagne")
        #expect(catalog.events.first?.raffle?.participantIDs.isEmpty == true)
        try catalog.removeRaffle(fromEvent: event.id)
        #expect(catalog.events.first?.raffle == nil)
    }

    @Test func raffleNeedsTitleAndPrize() throws {
        var (catalog, event) = try catalogWithEvent()
        #expect(throws: EventCatalog.CatalogError.emptyTitle) {
            try catalog.announceRaffle(titled: " ", prize: "Champagne", forEvent: event.id)
        }
        #expect(throws: EventCatalog.CatalogError.emptyPrize) {
            try catalog.announceRaffle(titled: "Win a bottle", prize: "", forEvent: event.id)
        }
    }

    @Test func unknownEventIsRejected() {
        var catalog = EventCatalog()
        #expect(throws: EventCatalog.CatalogError.unknownEvent) {
            try catalog.offerTickets(.standard, price: 1, quota: nil, forEvent: UUID())
        }
    }

    @Test func catalogRoundTripsThroughJSON() throws {
        var (catalog, event) = try catalogWithEvent()
        try catalog.offerTickets(.custom("Backstage"), price: 15000, quota: 20, forEvent: event.id)
        try catalog.announceRaffle(titled: "Win a bottle", prize: "Champagne", forEvent: event.id)
        let decoded = try JSONDecoder().decode(EventCatalog.self, from: JSONEncoder().encode(catalog))
        #expect(decoded == catalog)
    }
}
