import Foundation
import Combine
import SharedKit

@L11
protocol EventCatalogStoring {
    func load() -> EventCatalog?
    func save(_ catalog: EventCatalog) throws
}

@L11
class EventManagerViewModel: ObservableObject {
    @Published private(set) var catalog: EventCatalog
    @Published private(set) var errorMessage: String?
    private let store: EventCatalogStoring

    init(catalog: EventCatalog, store: EventCatalogStoring) {
        self.catalog = catalog
        self.store = store
    }

    @discardableResult
    func createEvent(titled title: String, description: String = "", location: String,
                     from start: Date, to end: Date, capacity: Int) -> Event? {
        var created: Event?
        apply {
            created = try $0.createEvent(titled: title, description: description, location: location,
                                         from: start, to: end, capacity: capacity)
        }
        return created
    }

    func removeEvent(id: UUID) {
        apply { $0.removeEvent(id: id) }
    }

    func offerTickets(_ type: TicketType, price: Double, quota: Int?, forEvent eventID: UUID) {
        apply { try $0.offerTickets(type, price: price, quota: quota, forEvent: eventID) }
    }

    func removeTicketOffer(id: UUID, fromEvent eventID: UUID) {
        apply { try $0.removeTicketOffer(id: id, fromEvent: eventID) }
    }

    func announceRaffle(titled title: String, prize: String, forEvent eventID: UUID) {
        apply { try $0.announceRaffle(titled: title, prize: prize, forEvent: eventID) }
    }

    func removeRaffle(fromEvent eventID: UUID) {
        apply { try $0.removeRaffle(fromEvent: eventID) }
    }

    private func apply(_ edit: (inout EventCatalog) throws -> Void) {
        var edited = catalog
        do {
            try edit(&edited)
            catalog = edited
            errorMessage = nil
            try store.save(edited)
        } catch let error as EventCatalog.CatalogError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "The events could not be saved"
        }
    }

    private static func message(for error: EventCatalog.CatalogError) -> String {
        switch error {
        case .emptyTitle: return "A title is required"
        case .emptyPrize: return "A prize is required"
        case .invalidTime: return "The event must end after it starts"
        case .invalidCapacity: return "An event needs at least one place"
        case .unknownEvent: return "The event no longer exists"
        case .negativePrice: return "The price cannot be negative"
        case .invalidQuota: return "A quota needs at least one place"
        case .duplicateTicketType(let type): return "\(type.displayName) tickets are already offered"
        case .quotaExceedsCapacity(let capacity): return "Ticket quotas exceed the capacity of \(capacity)"
        }
    }
}
