import Foundation
import Combine
import SharedKit

@M4
protocol PaymentProcessing {
    var isAvailable: Bool { get }
    func charge(_ amount: Double) -> Bool
}

extension PaymentProcessing {
    var isAvailable: Bool { true }
}

@M4
struct TestPaymentProcessor: PaymentProcessing {
    func charge(_ amount: Double) -> Bool { true }
}

@M4
struct UnavailablePaymentProcessor: PaymentProcessing {
    var isAvailable: Bool { false }
    func charge(_ amount: Double) -> Bool { false }
}

@M4 @K7
class TicketShopViewModel: ObservableObject {
    @Published private(set) var catalog: EventCatalog
    @Published private(set) var errorMessage: LocalizedStringResource?
    private let guestID: UUID
    private let payment: PaymentProcessing
    private let now: Date?

    init(catalog: EventCatalog, guestID: UUID, payment: PaymentProcessing, now: Date? = nil) {
        self.catalog = catalog
        self.guestID = guestID
        self.payment = payment
        self.now = now
    }

    private var currentDate: Date { now ?? Date() }

    var eventsOnSale: [Event] {
        catalog.events.filter { $0.endTime > currentDate }
    }

    var myTickets: [(event: Event, ticket: Ticket)] {
        catalog.tickets(of: guestID)
    }

    func buy(_ type: TicketType, quantity: Int, forEvent eventID: UUID) {
        do {
            try catalog.checkAvailability(type, quantity: quantity, forEvent: eventID, at: currentDate)
            guard payment.isAvailable else {
                errorMessage = "Payment is not available yet"
                return
            }
            let amount = try catalog.price(of: type, quantity: quantity, forEvent: eventID)
            guard payment.charge(amount) else {
                errorMessage = "The payment was declined"
                return
            }
            try catalog.purchase(type, quantity: quantity, forEvent: eventID, guestID: guestID, at: currentDate)
            errorMessage = nil
        } catch let error as EventCatalog.CatalogError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "The purchase failed"
        }
    }

    private static func message(for error: EventCatalog.CatalogError) -> LocalizedStringResource {
        switch error {
        case .notOffered: return "This ticket type is not offered"
        case .soldOut(let type): return "\(type.displayName) tickets are sold out"
        case .eventFull: return "The event is full"
        case .eventOver: return "The event is over"
        case .invalidQuantity: return "You can buy 1 to 10 tickets at once"
        case .noRaffle: return "There is no raffle for this event"
        case .alreadyEntered: return "You are already registered for this raffle"
        case .unknownEvent: return "The event no longer exists"
        default: return "The purchase failed"
        }
    }
}
