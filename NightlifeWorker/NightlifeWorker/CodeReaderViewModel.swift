//
//  CodeReaderViewModel.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import Foundation
import Combine
import SharedKit

/// Access to tickets and their holders (production: CloudKit).
protocol TicketRepository: AnyObject {
    func ticket(serialNumber: String) -> Ticket?
    func guest(id: UUID) -> GuestUser?
    func save(_ ticket: Ticket)
}

/// Routes every scanned code to ticket admission or zone check-in (K7, K16).
class CodeReaderViewModel: ObservableObject {
    enum Result: Equatable {
        case admitted(guestName: String, ticketType: String)
        case ticketAlreadyUsed
        case ticketForAnotherEvent
        case unknownTicket
        case checkedIn(zoneName: String)
        case checkInFailed(WorkerPosition.CheckInError)
        case unknownCode
    }

    @Published private(set) var lastResult: Result?
    private let eventID: UUID
    private let tickets: TicketRepository
    private let zoneCheckIn: ZoneCheckInViewModel

    init(eventID: UUID, tickets: TicketRepository, zoneCheckIn: ZoneCheckInViewModel) {
        self.eventID = eventID
        self.tickets = tickets
        self.zoneCheckIn = zoneCheckIn
    }

    var message: String? {
        switch lastResult {
        case .admitted(let guestName, let ticketType): return "Admitted: \(guestName) – \(ticketType)"
        case .ticketAlreadyUsed: return "Ticket already used"
        case .ticketForAnotherEvent: return "Ticket is for another event"
        case .unknownTicket: return "Unknown ticket"
        case .checkedIn(let zoneName): return "Checked in: \(zoneName)"
        case .checkInFailed(.notOnShift): return "Not on shift"
        case .checkInFailed(.invalidCode): return "Unknown zone"
        case .unknownCode: return "Unknown code"
        case nil: return nil
        }
    }

    func handle(payload: String) {
        switch ScannedCode(payload: payload) {
        case .ticket(let serialNumber):
            lastResult = admit(serialNumber: serialNumber)
        case .zone:
            zoneCheckIn.scan(payload)
            if let error = zoneCheckIn.lastError {
                lastResult = .checkInFailed(error)
            } else {
                lastResult = .checkedIn(zoneName: zoneCheckIn.currentZone?.name ?? "")
            }
        case .unknown:
            lastResult = .unknownCode
        }
    }

    private func admit(serialNumber: String) -> Result {
        guard var ticket = tickets.ticket(serialNumber: serialNumber) else { return .unknownTicket }
        switch ticket.admit(toEvent: eventID) {
        case .admitted:
            tickets.save(ticket)
            let guestName = tickets.guest(id: ticket.guestID)?.name ?? ""
            return .admitted(guestName: guestName, ticketType: ticket.ticketType.displayName)
        case .alreadyUsed:
            return .ticketAlreadyUsed
        case .wrongEvent:
            return .ticketForAnotherEvent
        }
    }
}
