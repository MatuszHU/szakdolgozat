import Foundation
import Testing
@testable import SharedKit

@Suite("Panic mode")
struct PanicTests {

    private let anna = WorkerUser(appleID: "a", name: "Anna", role: .bartender, payPeriod: .weekly)
    private let bela = WorkerUser(appleID: "b", name: "Béla", role: .security, payPeriod: .weekly)
    private let csaba = WorkerUser(appleID: "c", name: "Csaba", role: .security, payPeriod: .weekly)
    private let dora = WorkerUser(appleID: "d", name: "Dóra", role: .custom("cloakroom"), payPeriod: .weekly)
    private var staff: [WorkerUser] { [anna, bela, csaba, dora] }

    @Test func roleDisplayNames() {
        #expect(WorkerRole.bartender.displayName == "bartender")
        #expect(WorkerRole.security.displayName == "security")
        #expect(WorkerRole.custom("cloakroom").displayName == "cloakroom")
    }

    @Test func securityStaffAreTheDefaultRecipients() {
        let recipients = PanicAlert.recipients(for: anna, among: staff)
        #expect(Set(recipients) == [bela.id, csaba.id])
    }

    @Test func senderIsNeverARecipient() {
        let recipients = PanicAlert.recipients(for: bela, among: staff)
        #expect(recipients == [csaba.id])
    }

    @Test func configuredRolesAreNotified() {
        let recipients = PanicAlert.recipients(for: anna, among: staff, notifying: [.security, .custom("cloakroom")])
        #expect(Set(recipients) == [bela.id, csaba.id, dora.id])
    }

    @Test func messageContainsNameRoleAndZone() {
        #expect(PanicAlert.message(for: anna, zone: Zone(name: "Bar")) == "Anna (bartender) – Bar")
    }

    @Test func messageWithoutKnownZone() {
        #expect(PanicAlert.message(for: anna, zone: nil) == "Anna (bartender) – unknown location")
    }

    @Test func recipientCanAcknowledge() {
        var alert = PanicAlert(workerID: anna.id)
        let acknowledged = alert.acknowledge(by: bela.id)
        #expect(acknowledged)
        #expect(alert.isAcknowledged)
        #expect(alert.acknowledgedByID == bela.id)
        #expect(alert.acknowledgedTimestamp != nil)
    }

    @Test func onlyFirstAcknowledgementCounts() {
        var alert = PanicAlert(workerID: anna.id)
        _ = alert.acknowledge(by: bela.id)
        let second = alert.acknowledge(by: csaba.id)
        #expect(!second)
        #expect(alert.acknowledgedByID == bela.id)
    }

    @Test func senderCannotAcknowledgeOwnAlert() {
        var alert = PanicAlert(workerID: anna.id)
        let acknowledged = alert.acknowledge(by: anna.id)
        #expect(!acknowledged)
        #expect(!alert.isAcknowledged)
    }
}
