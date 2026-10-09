import Foundation
import Combine
import SharedKit

@K13
struct NotificationSources {
    var workerID: UUID
    var inventory = Inventory()
    var panicAlerts: [PanicAlert] = []
    var staff: [WorkerUser] = []
    var venue = Venue(name: "")
    var shifts: [Shift] = []
}

@K13
class NotificationsViewModel: ObservableObject {
    @Published private(set) var inbox: NotificationInbox
    @Published var kindFilter: NotificationKind?
    private let sources: () -> NotificationSources
    private let now: () -> Date

    init(inbox: NotificationInbox = NotificationInbox(), sources: @escaping () -> NotificationSources,
         now: @escaping () -> Date = Date.init) {
        self.inbox = inbox
        self.sources = sources
        self.now = now
    }

    var visible: [WorkerNotification] { inbox.notifications(of: kindFilter) }
    var unreadCount: Int { inbox.unreadCount }

    func open() {
        let current = sources()
        let date = now()
        inbox.receiveAssignments(current.shifts, venue: current.venue, for: current.workerID, at: date)
        inbox.receiveDecisions(of: current.inventory.requests, items: current.inventory.items,
                               for: current.workerID, at: date)
        inbox.receivePanicAlerts(current.panicAlerts, staff: current.staff, venue: current.venue,
                                 for: current.workerID)
    }

    func markRead(id: UUID) {
        inbox.markRead(id: id)
    }

    func markAllRead() {
        inbox.markAllRead()
    }
}
