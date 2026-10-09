import Foundation

@L11 @M4
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

@L11 @M7
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

@L11
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
        case notOffered
        case soldOut(TicketType)
        case eventFull
        case eventOver
        case invalidQuantity
        case noRaffle
        case alreadyEntered
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

    @M7
    public func currentRaffles(at date: Date) -> [(event: Event, raffle: Raffle)] {
        events
            .filter { $0.endTime > date }
            .compactMap { event in event.raffle.map { (event, $0) } }
    }

    @M7
    public func hasEnteredRaffle(ofEvent eventID: UUID, guestID: UUID) -> Bool {
        events.first { $0.id == eventID }?.raffle?.participantIDs.contains(guestID) ?? false
    }

    @M7
    public mutating func enterRaffle(ofEvent eventID: UUID, guestID: UUID, at date: Date) throws {
        try edit(eventID) { event in
            guard var raffle = event.raffle else { throw CatalogError.noRaffle }
            guard date < event.endTime else { throw CatalogError.eventOver }
            guard !raffle.participantIDs.contains(guestID) else { throw CatalogError.alreadyEntered }
            raffle.participantIDs.append(guestID)
            event.raffle = raffle
        }
    }

    @M4
    public func price(of type: TicketType, quantity: Int, forEvent eventID: UUID) throws -> Double {
        guard let event = events.first(where: { $0.id == eventID }) else { throw CatalogError.unknownEvent }
        guard let offer = event.ticketOffers.first(where: { $0.type == type }) else { throw CatalogError.notOffered }
        return offer.price * Double(quantity)
    }

    @M4
    public func checkAvailability(_ type: TicketType, quantity: Int, forEvent eventID: UUID, at date: Date) throws {
        guard (1...10).contains(quantity) else { throw CatalogError.invalidQuantity }
        guard let event = events.first(where: { $0.id == eventID }) else { throw CatalogError.unknownEvent }
        guard date < event.endTime else { throw CatalogError.eventOver }
        guard let offer = event.ticketOffers.first(where: { $0.type == type }) else { throw CatalogError.notOffered }
        if let quota = offer.quota, event.tickets.filter({ $0.ticketType == type }).count + quantity > quota {
            throw CatalogError.soldOut(type)
        }
        guard event.tickets.count + quantity <= event.capacity else { throw CatalogError.eventFull }
    }

    @M4 @K7
    @discardableResult
    public mutating func purchase(_ type: TicketType, quantity: Int, forEvent eventID: UUID,
                                  guestID: UUID, at date: Date) throws -> [Ticket] {
        try checkAvailability(type, quantity: quantity, forEvent: eventID, at: date)
        let price = try price(of: type, quantity: 1, forEvent: eventID)
        let serials = newSerialNumbers(quantity)
        var issued: [Ticket] = []
        try edit(eventID) { event in
            for serial in serials {
                let ticket = Ticket(eventID: eventID, guestID: guestID, purchaseDate: date, passTypeIdentifier: "",
                                    serialNumber: serial, price: price, ticketType: type, entrance: "")
                event.tickets.append(ticket)
                issued.append(ticket)
            }
        }
        return issued
    }

    @M4
    public func tickets(of guestID: UUID) -> [(event: Event, ticket: Ticket)] {
        events.flatMap { event in
            event.tickets.filter { $0.guestID == guestID }.map { (event: event, ticket: $0) }
        }
    }

    private func newSerialNumbers(_ count: Int) -> [String] {
        var used = Set(events.flatMap(\.tickets).map(\.serialNumber))
        var serials: [String] = []
        while serials.count < count {
            let serial = "NL-" + UUID().uuidString.prefix(8)
            if used.insert(serial).inserted { serials.append(serial) }
        }
        return serials
    }

    private mutating func edit(_ eventID: UUID, _ change: (inout Event) throws -> Void) throws {
        guard let index = events.firstIndex(where: { $0.id == eventID }) else { throw CatalogError.unknownEvent }
        var event = events[index]
        try change(&event)
        events[index] = event
    }
}
