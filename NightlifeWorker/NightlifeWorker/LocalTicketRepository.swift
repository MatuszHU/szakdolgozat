//
//  LocalTicketRepository.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
import SharedKit

/// In-memory tickets and guests; used by tests and until CloudKit sync (N2) is implemented.
final class LocalTicketRepository: TicketRepository {
    var tickets: [Ticket]
    var guests: [GuestUser]

    init(tickets: [Ticket] = [], guests: [GuestUser] = []) {
        self.tickets = tickets
        self.guests = guests
    }

    func ticket(serialNumber: String) -> Ticket? {
        tickets.first { $0.serialNumber == serialNumber }
    }

    func guest(id: UUID) -> GuestUser? {
        guests.first { $0.id == id }
    }

    func save(_ ticket: Ticket) {
        if let index = tickets.firstIndex(where: { $0.id == ticket.id }) {
            tickets[index] = ticket
        }
    }
}
