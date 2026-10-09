import Foundation
import Testing
@testable import SharedKit

@Suite("Raffle entries")
@M7
struct RaffleEntryTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let guest = UUID()

    private func catalog() throws -> (EventCatalog, neon: Event, retro: Event, past: Event, quiet: Event) {
        var catalog = EventCatalog()
        let day: TimeInterval = 86400
        let retro = try catalog.createEvent(titled: "Retro Party", location: "Club Neon", from: now.addingTimeInterval(8 * day),
                                            to: now.addingTimeInterval(8 * day + 21600), capacity: 100)
        let neon = try catalog.createEvent(titled: "Neon Night", location: "Club Neon", from: now.addingTimeInterval(day),
                                           to: now.addingTimeInterval(day + 21600), capacity: 100)
        let past = try catalog.createEvent(titled: "Past Party", location: "Club Neon", from: now.addingTimeInterval(-7 * day),
                                           to: now.addingTimeInterval(-7 * day + 21600), capacity: 100)
        let quiet = try catalog.createEvent(titled: "Quiet Night", location: "Club Neon", from: now.addingTimeInterval(3 * day),
                                            to: now.addingTimeInterval(3 * day + 21600), capacity: 100)
        try catalog.announceRaffle(titled: "Free entry", prize: "2 tickets", forEvent: retro.id)
        try catalog.announceRaffle(titled: "VIP table", prize: "Bottle of champagne", details: "Drawn at 2:00",
                                   forEvent: neon.id)
        try catalog.announceRaffle(titled: "Lucky draw", prize: "T-shirt", forEvent: past.id)
        return (catalog, neon, retro, past, quiet)
    }

    @Test func currentRafflesAreThoseOfEventsNotEndedInEventOrder() throws {
        let (catalog, _, _, _, _) = try catalog()
        #expect(catalog.currentRaffles(at: now).map { "\($0.event.title) – \($0.raffle.title)" }
                == ["Neon Night – VIP table", "Retro Party – Free entry"])
    }

    @Test func aGuestEntersOnce() throws {
        var (catalog, neon, _, _, _) = try catalog()
        try catalog.enterRaffle(ofEvent: neon.id, guestID: guest, at: now)
        #expect(catalog.hasEnteredRaffle(ofEvent: neon.id, guestID: guest))
        #expect(throws: EventCatalog.CatalogError.alreadyEntered) {
            try catalog.enterRaffle(ofEvent: neon.id, guestID: guest, at: now)
        }
        #expect(catalog.events.first { $0.id == neon.id }?.raffle?.participantIDs == [guest])
    }

    @Test func otherGuestsCanEnterToo() throws {
        var (catalog, neon, _, _, _) = try catalog()
        try catalog.enterRaffle(ofEvent: neon.id, guestID: guest, at: now)
        try catalog.enterRaffle(ofEvent: neon.id, guestID: UUID(), at: now)
        #expect(catalog.events.first { $0.id == neon.id }?.raffle?.participantIDs.count == 2)
    }

    @Test func noEntryAfterTheEvent() throws {
        var (catalog, _, _, past, _) = try catalog()
        #expect(throws: EventCatalog.CatalogError.eventOver) {
            try catalog.enterRaffle(ofEvent: past.id, guestID: guest, at: now)
        }
    }

    @Test func noEntryWithoutARaffle() throws {
        var (catalog, _, _, _, quiet) = try catalog()
        #expect(throws: EventCatalog.CatalogError.noRaffle) {
            try catalog.enterRaffle(ofEvent: quiet.id, guestID: guest, at: now)
        }
        #expect(throws: EventCatalog.CatalogError.unknownEvent) {
            try catalog.enterRaffle(ofEvent: UUID(), guestID: guest, at: now)
        }
    }
}
