//
//  EventCatalog.swift
//
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation

/// A ticket type sold for an event, with its price (HUF) and an optional quota (L11, M4).
public struct TicketOffer: Identifiable, Codable, Hashable {
    public let id: UUID
    public var type: TicketType
    public var price: Double
    public var quota: Int?

    public init(id: UUID = UUID(), type: TicketType, price: Double, quota: Int? = nil) {
        self.id = id
        self.type = type
        self.price = price
        self.quota = quota
    }
}

/// A raffle announced for an event (L11, M7).
public struct Raffle: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var prize: String
    public var details: String
    public var participantIDs: [UUID]

    public init(id: UUID = UUID(), title: String, prize: String, details: String = "", participantIDs: [UUID] = []) {
        self.id = id
        self.title = title
        self.prize = prize
        self.details = details
        self.participantIDs = participantIDs
    }
}

/// The administrator's events with their ticket offers and raffles (L11).
public struct EventCatalog: Codable, Hashable {
    public enum CatalogError: Error, Equatable {
        case emptyTitle
        case emptyPrize
        case invalidTime
        case invalidCapacity
        case unknownEvent
        case negativePrice
        case invalidQuota
        case duplicateTicketType(TicketType)
        case quotaExceedsCapacity(Int)
    }

    public private(set) var events: [Event] = []

    public init() {}

    @discardableResult
    public mutating func createEvent(titled title: String, description: String = "", location: String,
                                     from start: Date, to end: Date, capacity: Int) throws -> Event {
        let title = title.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { throw CatalogError.emptyTitle }
        guard start < end else { throw CatalogError.invalidTime }
        guard capacity > 0 else { throw CatalogError.invalidCapacity }
        let event = Event(title: title, description: description, startTime: start, endTime: end,
                          location: location, capacity: capacity)
        events.append(event)
        events.sort { $0.startTime < $1.startTime }
        return event
    }

    public mutating func removeEvent(id: UUID) {
        events.removeAll { $0.id == id }
    }

    public mutating func offerTickets(_ type: TicketType, price: Double, quota: Int?, forEvent eventID: UUID) throws {
        try edit(eventID) { event in
            guard price >= 0 else { throw CatalogError.negativePrice }
            if let quota, quota <= 0 { throw CatalogError.invalidQuota }
            guard !event.ticketOffers.contains(where: { $0.type == type }) else {
                throw CatalogError.duplicateTicketType(type)
            }
            let reserved = event.ticketOffers.compactMap(\.quota).reduce(0, +) + (quota ?? 0)
            guard reserved <= event.capacity else { throw CatalogError.quotaExceedsCapacity(event.capacity) }
            event.ticketOffers.append(TicketOffer(type: type, price: price, quota: quota))
        }
    }

    public mutating func removeTicketOffer(id: UUID, fromEvent eventID: UUID) throws {
        try edit(eventID) { $0.ticketOffers.removeAll { $0.id == id } }
    }

    public mutating func announceRaffle(titled title: String, prize: String, details: String = "",
                                        forEvent eventID: UUID) throws {
        let title = title.trimmingCharacters(in: .whitespaces)
        let prize = prize.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { throw CatalogError.emptyTitle }
        guard !prize.isEmpty else { throw CatalogError.emptyPrize }
        try edit(eventID) { $0.raffle = Raffle(title: title, prize: prize, details: details) }
    }

    public mutating func removeRaffle(fromEvent eventID: UUID) throws {
        try edit(eventID) { $0.raffle = nil }
    }

    private mutating func edit(_ eventID: UUID, _ change: (inout Event) throws -> Void) throws {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { throw CatalogError.unknownEvent }
        var event = events[index]
        try change(&event)
        events[index] = event
    }
}
