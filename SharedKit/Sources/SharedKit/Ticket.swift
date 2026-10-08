//
//  Ticket.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//


import Foundation

public enum TicketType: Codable {
    case standard
    case vip
    case custom(String)
}

public struct Ticket: Identifiable, Codable {
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
    public var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .vip: return "VIP"
        case .custom(let name): return name
        }
    }
}

extension Ticket {
    public static let qrPrefix = "nightlife://ticket/"

    public enum AdmissionResult: Equatable {
        case admitted
        case alreadyUsed
        case wrongEvent
    }

    public var qrPayload: String { Ticket.qrPrefix + serialNumber }

    /// Admits the ticket's holder to the given event; a ticket can be used only once (K7, M4).
    public mutating func admit(toEvent eventID: UUID) -> AdmissionResult {
        guard self.eventID == eventID else { return .wrongEvent }
        guard !isUsed else { return .alreadyUsed }
        isUsed = true
        return .admitted
    }
}
