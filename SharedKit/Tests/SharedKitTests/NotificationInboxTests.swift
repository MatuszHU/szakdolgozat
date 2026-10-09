import Foundation
import Testing
@testable import SharedKit

@Suite("Notification inbox")
@K13
struct NotificationInboxTests {
    private let base = Date(timeIntervalSince1970: 1_800_000_000)
    private let anna = WorkerUser(appleID: "a", name: "Anna", role: .security, payPeriod: .weekly)
    private let bela = WorkerUser(appleID: "b", name: "Béla", role: .bartender, payPeriod: .weekly)

    private func note(_ kind: NotificationKind, _ title: String, minutes: Double) -> WorkerNotification {
        WorkerNotification(kind: kind, title: title, body: "", date: base.addingTimeInterval(minutes * 60))
    }

    private func venue() throws -> (Venue, bar: Zone) {
        var venue = Venue(name: "Club Neon")
        let floor = try venue.addFloor(named: "Ground floor", level: 0, width: 10, height: 10)
        var bar: Zone!
        try venue.editFloor(id: floor.id) {
            bar = try $0.addZone(named: "Bar", outline: [PlanPoint(x: 0, y: 0), PlanPoint(x: 1, y: 0), PlanPoint(x: 1, y: 1)])
        }
        return (venue, bar)
    }

    @Test func newestFirstAndUnread() {
        var inbox = NotificationInbox()
        inbox.receive(note(.admin, "Old", minutes: 0))
        inbox.receive(note(.system, "New", minutes: 10))
        #expect(inbox.notifications.map(\.title) == ["New", "Old"])
        #expect(inbox.unreadCount == 2)
    }

    @Test func theSameNotificationIsReceivedOnce() {
        var inbox = NotificationInbox()
        let first = note(.system, "Once", minutes: 0)
        let added = inbox.receive(first)
        let addedAgain = inbox.receive(first)
        #expect(added && !addedAgain)
        #expect(inbox.notifications.count == 1)
    }

    @Test func readingOneOrAll() {
        var inbox = NotificationInbox()
        let first = note(.admin, "A", minutes: 0)
        inbox.receive(first)
        inbox.receive(note(.user, "B", minutes: 1))
        inbox.markRead(id: first.id)
        #expect(inbox.unreadCount == 1)
        inbox.markAllRead()
        #expect(inbox.unreadCount == 0)
    }

    @Test func aReadNotificationStaysReadWhenReceivedAgain() {
        var inbox = NotificationInbox()
        let first = note(.admin, "A", minutes: 0)
        inbox.receive(first)
        inbox.markRead(id: first.id)
        inbox.receive(first)
        #expect(inbox.unreadCount == 0)
    }

    @Test func filteringByKind() {
        var inbox = NotificationInbox()
        inbox.receive(note(.admin, "A", minutes: 0))
        inbox.receive(note(.user, "U", minutes: 1))
        #expect(inbox.notifications(of: .admin).map(\.title) == ["A"])
        #expect(inbox.notifications(of: nil).count == 2)
    }

    @Test func decidedRequestsOfTheWorkerNotify() throws {
        var inventory = Inventory()
        let ice = try inventory.addItem(named: "Ice", category: "Bar", quantity: 20, unit: "kg", minimum: 0)
        let lime = try inventory.addItem(named: "Lime", category: "Fruit", quantity: 5, unit: "kg", minimum: 0)
        let glasses = try inventory.addItem(named: "Glasses", category: "Bar", quantity: 50, unit: "pcs", minimum: 0)
        let approved = try inventory.receiveRequest(from: anna.id, itemID: ice.id, quantity: 5)
        let rejected = try inventory.receiveRequest(from: anna.id, itemID: lime.id, quantity: 2)
        try inventory.receiveRequest(from: anna.id, itemID: glasses.id, quantity: 10)
        let others = try inventory.receiveRequest(from: bela.id, itemID: ice.id, quantity: 1)
        try inventory.approveRequest(id: approved.id)
        try inventory.rejectRequest(id: rejected.id)
        try inventory.approveRequest(id: others.id)
        var inbox = NotificationInbox()
        inbox.receiveDecisions(of: inventory.requests, items: inventory.items, for: anna.id, at: base)
        #expect(Set(inbox.notifications.map { "\($0.title): \($0.body)" }) == ["Request approved: 5 kg Ice",
                                                                             "Request rejected: 2 kg Lime"])
        #expect(inbox.notifications.allSatisfy { $0.kind == .system && $0.date == base })
    }

    @Test func panicAlertsSentToTheWorkerNotify() throws {
        let (venue, bar) = try venue()
        let fromBela = PanicAlert(workerID: bela.id, timestamp: base, zoneID: bar.id)
        let fromAnna = PanicAlert(workerID: anna.id, timestamp: base)
        var inbox = NotificationInbox()
        inbox.receivePanicAlerts([fromBela, fromAnna], staff: [anna, bela], venue: venue, for: anna.id)
        #expect(inbox.notifications.map(\.body) == ["Béla (bartender) – Bar"])
        #expect(inbox.notifications.first?.kind == .user)
        #expect(inbox.notifications.first?.title == "Panic alert")
        #expect(inbox.notifications.first?.date == base)
    }

    @Test func panicAlertsDoNotReachOtherRoles() throws {
        let (venue, bar) = try venue()
        let fromAnna = PanicAlert(workerID: anna.id, timestamp: base, zoneID: bar.id)
        var inbox = NotificationInbox()
        inbox.receivePanicAlerts([fromAnna], staff: [anna, bela], venue: venue, for: bela.id)
        #expect(inbox.notifications.isEmpty)
    }

    @Test func assignedShiftsThatHaveNotEndedNotify() throws {
        let (venue, bar) = try venue()
        let coming = Shift(workerIDs: [anna.id], startTime: base.addingTimeInterval(3600),
                           endTime: base.addingTimeInterval(7200), zoneID: bar.id)
        let finished = Shift(workerIDs: [anna.id], startTime: base.addingTimeInterval(-7200),
                             endTime: base.addingTimeInterval(-3600))
        let others = Shift(workerIDs: [bela.id], startTime: base.addingTimeInterval(3600),
                           endTime: base.addingTimeInterval(7200))
        let unplaced = Shift(workerIDs: [anna.id], startTime: base.addingTimeInterval(9000),
                             endTime: base.addingTimeInterval(12000))
        var inbox = NotificationInbox()
        inbox.receiveAssignments([coming, finished, others, unplaced], venue: venue, for: anna.id, at: base)
        #expect(inbox.notifications.map(\.body).sorted() == ["Ground floor – Bar", "No zone"])
        #expect(inbox.notifications.allSatisfy { $0.kind == .admin && $0.title == "New shift" })
        #expect(Set(inbox.notifications.compactMap(\.eventDate)) == [coming.startTime, unplaced.startTime])
    }

    @Test func theInboxIsSavedAndLoaded() throws {
        var inbox = NotificationInbox()
        inbox.receive(note(.admin, "A", minutes: 0))
        let decoded = try JSONDecoder().decode(NotificationInbox.self, from: JSONEncoder().encode(inbox))
        #expect(decoded == inbox)
    }
}
