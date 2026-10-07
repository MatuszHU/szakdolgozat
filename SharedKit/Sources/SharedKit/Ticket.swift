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
