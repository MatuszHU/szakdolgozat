import Foundation

@L11 @M4
public enum TicketType: Codable, Hashable {
    case standard
    case vip
    case custom(String)
}

@M4 @K7
public struct Ticket: Identifiable, Codable, Hashable {
    public let id: UUID
    public let eventID: UUID
    public let guestID: UUID
    public var purchaseDate: Date
    public var isUsed: Bool
    public var passTypeIdentifier: String
    public var serialNumber: String
    public var price: Double
    public var ticketType: TicketType
    public var entrance: String
    
    public init(id: UUID = UUID(), eventID: UUID, guestID: UUID, purchaseDate: Date = Date(), isUsed: Bool = false, passTypeIdentifier: String, serialNumber: String, price: Double, ticketType: TicketType, entrance: String) {
        self.id = id
        self.eventID = eventID
        self.guestID = guestID
        self.purchaseDate = purchaseDate
        self.isUsed = isUsed
        self.passTypeIdentifier = passTypeIdentifier
        self.serialNumber = serialNumber
        self.price = price
        self.ticketType = ticketType
        self.entrance = entrance
    }
}

extension TicketType {
    @L11 @M4
    public var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .vip: return "VIP"
        case .custom(let name): return name
        }
    }
}

extension Ticket {
    @K7 @M4
    public static let qrPrefix = "nightlife://ticket/"

    @K7 @M4
    public enum AdmissionResult: Equatable {
        case admitted
        case alreadyUsed
        case wrongEvent
    }

    @K7 @M4
    public var qrPayload: String { Ticket.qrPrefix + serialNumber }

    @K7 @M4
    public mutating func admit(toEvent eventID: UUID) -> AdmissionResult {
        guard self.eventID == eventID else { return .wrongEvent }
        guard !isUsed else { return .alreadyUsed }
        isUsed = true
        return .admitted
    }
}
