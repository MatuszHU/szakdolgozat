import Foundation

@K13
public enum NotificationKind: String, Codable, CaseIterable, Sendable {
    case system
    case user
    case admin
}

@K13
public struct WorkerNotification: Identifiable, Codable, Hashable {
    public let id: UUID
    public let kind: NotificationKind
    public let title: String
    public let body: String
    public let date: Date
    public let eventDate: Date?
    public var isRead: Bool

    public init(id: UUID = UUID(), kind: NotificationKind, title: String, body: String, date: Date,
                eventDate: Date? = nil, isRead: Bool = false) {
        self.id = id
        self.kind = kind
        self.title = title
        self.body = body
        self.date = date
        self.eventDate = eventDate
        self.isRead = isRead
    }
}

@K13
public struct NotificationInbox: Codable, Hashable {
    public private(set) var notifications: [WorkerNotification] = []

    public init() {}

    public var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    public func notifications(of kind: NotificationKind?) -> [WorkerNotification] {
        guard let kind else { return notifications }
        return notifications.filter { $0.kind == kind }
    }

    @discardableResult
    public mutating func receive(_ notification: WorkerNotification) -> Bool {
        guard !notifications.contains(where: { $0.id == notification.id }) else { return false }
        notifications.append(notification)
        notifications.sort { $0.date > $1.date }
        return true
    }

    public mutating func markRead(id: UUID) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isRead = true
    }

    public mutating func markAllRead() {
        for index in notifications.indices { notifications[index].isRead = true }
    }

    @K17
    public mutating func receiveDecisions(of requests: [SupplyRequest], items: [SupplyItem], for workerID: UUID,
                                          at date: Date) {
        for request in requests where request.workerID == workerID && request.status != .pending {
            let item = items.first { $0.id == request.itemID }
            let amount = request.quantity.formatted(.number.precision(.fractionLength(0...2)))
            receive(WorkerNotification(id: request.id, kind: .system,
                                       title: request.status == .approved ? "Request approved" : "Request rejected",
                                       body: "\(amount) \(item?.unit ?? "") \(item?.name ?? "")", date: date))
        }
    }

    @K8
    public mutating func receivePanicAlerts(_ alerts: [PanicAlert], staff: [WorkerUser], venue: Venue,
                                            for workerID: UUID) {
        for alert in alerts {
            guard let sender = staff.first(where: { $0.id == alert.workerID }),
                  PanicAlert.recipients(for: sender, among: staff).contains(workerID) else { continue }
            let zone = alert.zoneID.flatMap { id in venue.floors.flatMap(\.zones).first { $0.id == id } }
            receive(WorkerNotification(id: alert.id, kind: .user, title: "Panic alert",
                                       body: PanicAlert.message(for: sender, zone: zone), date: alert.timestamp))
        }
    }

    @L3 @K5
    public mutating func receiveAssignments(_ shifts: [Shift], venue: Venue, for workerID: UUID, at date: Date) {
        let schedule = WorkerSchedule(workerID: workerID, shifts: shifts, venue: venue, at: date)
        for entry in schedule.upcoming {
            receive(WorkerNotification(id: entry.shift.id, kind: .admin, title: "New shift",
                                       body: entry.place ?? "No zone", date: date, eventDate: entry.shift.startTime))
        }
    }
}
