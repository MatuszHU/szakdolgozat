import Foundation
import Combine
import SharedKit

@M7
class RaffleViewModel: ObservableObject {
    struct Item: Identifiable {
        let event: Event
        let raffle: Raffle
        let isEntered: Bool

        var id: UUID { raffle.id }
    }

    @Published private(set) var catalog: EventCatalog
    @Published private(set) var message: LocalizedStringResource?
    @Published private(set) var isError = false
    private let guestID: UUID
    private let now: () -> Date

    init(catalog: EventCatalog, guestID: UUID, now: @escaping () -> Date = Date.init) {
        self.catalog = catalog
        self.guestID = guestID
        self.now = now
    }

    var raffles: [Item] {
        catalog.currentRaffles(at: now()).map {
            Item(event: $0.event, raffle: $0.raffle,
                 isEntered: catalog.hasEnteredRaffle(ofEvent: $0.event.id, guestID: guestID))
        }
    }

    func register(forEvent eventID: UUID) {
        do {
            try catalog.enterRaffle(ofEvent: eventID, guestID: guestID, at: now())
            message = "You are registered. Good luck!"
            isError = false
        } catch let error as EventCatalog.CatalogError {
            message = Self.message(for: error)
            isError = true
        } catch {
            message = "The registration failed"
            isError = true
        }
    }

    private static func message(for error: EventCatalog.CatalogError) -> LocalizedStringResource {
        switch error {
        case .alreadyEntered: return "You are already registered for this raffle"
        case .eventOver: return "The event is over"
        case .noRaffle: return "There is no raffle for this event"
        default: return "The registration failed"
        }
    }
}
