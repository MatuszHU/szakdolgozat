//
//  Event.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//


import Foundation

public struct Event: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String
    public var startTime: Date
    public var endTime: Date
    public var location: String
    public var capacity: Int
    public var tickets: [Ticket]
    public var ticketOffers: [TicketOffer] = []
    public var raffle: Raffle?
    
    public init(id: UUID = UUID(), title: String, description: String, startTime: Date, endTime: Date, location: String, capacity: Int, tickets: [Ticket] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.capacity = capacity
        self.tickets = tickets
    }
}