import Foundation
import SharedKit

@K7
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
