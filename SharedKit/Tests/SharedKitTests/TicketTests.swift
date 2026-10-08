import Foundation
import Testing
@testable import SharedKit

private func makeTicket(eventID: UUID, used: Bool = false, type: TicketType = .standard) -> Ticket {
    Ticket(eventID: eventID, guestID: UUID(), isUsed: used, passTypeIdentifier: "",
           serialNumber: "T-001", price: 0, ticketType: type, entrance: "")
}

@Suite("ScannedCode")
struct ScannedCodeTests {

    @Test func recognisesZoneCode() {
        let zone = Zone(name: "Bar")
        #expect(ScannedCode(payload: zone.qrPayload) == .zone(zone.id))
    }

    @Test func recognisesTicketCode() {
        let ticket = makeTicket(eventID: UUID())
        #expect(ticket.qrPayload == "nightlife://ticket/T-001")
        #expect(ScannedCode(payload: ticket.qrPayload) == .ticket(serialNumber: "T-001"))
    }

    @Test(arguments: [
        "https://example.com/menu",
        "nightlife://ticket/",
        "nightlife://zone/not-a-uuid",
        "",
    ])
    func everythingElseIsUnknown(_ payload: String) {
        #expect(ScannedCode(payload: payload) == .unknown)
    }
}

@Suite("Ticket admission")
struct TicketAdmissionTests {

    private let tonight = UUID()

    @Test func validTicketIsAdmittedAndMarkedUsed() {
        var ticket = makeTicket(eventID: tonight)
        let result = ticket.admit(toEvent: tonight)
        #expect(result == .admitted)
        #expect(ticket.isUsed)
    }

    @Test func usedTicketIsRejected() {
        var ticket = makeTicket(eventID: tonight, used: true)
        let result = ticket.admit(toEvent: tonight)
        #expect(result == .alreadyUsed)
    }

    @Test func ticketForAnotherEventIsRejectedAndStaysUnused() {
        var ticket = makeTicket(eventID: UUID())
        let result = ticket.admit(toEvent: tonight)
        #expect(result == .wrongEvent)
        #expect(!ticket.isUsed)
    }

    @Test func ticketTypeDisplayNames() {
        #expect(TicketType.standard.displayName == "Standard")
        #expect(TicketType.vip.displayName == "VIP")
        #expect(TicketType.custom("Backstage").displayName == "Backstage")
    }
}
