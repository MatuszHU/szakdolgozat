import Foundation

@K8 @N4
public struct PanicAlert: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public let timestamp: Date
    public var zoneID: UUID?
    public var isAcknowledged: Bool
    public var acknowledgedByID: UUID?
    public var acknowledgedTimestamp: Date?
    
    public init(id: UUID = UUID(), workerID: UUID, timestamp: Date = Date(), zoneID: UUID? = nil, isAcknowledged: Bool = false, acknowledgedByID: UUID? = nil, acknowledgedTimestamp: Date? = nil) {
        self.id = id
        self.workerID = workerID
        self.timestamp = timestamp
        self.zoneID = zoneID
        self.isAcknowledged = isAcknowledged
        self.acknowledgedByID = acknowledgedByID
        self.acknowledgedTimestamp = acknowledgedTimestamp
    }
}

extension PanicAlert {

    @K8
    public static func recipients(for sender: WorkerUser,
                                  among staff: [WorkerUser],
                                  notifying roles: Set<WorkerRole> = [.security]) -> [UUID] {
        staff
            .filter { $0.id != sender.id && roles.contains($0.role) }
            .map(\.id)
    }

    @K8
    public static func message(for worker: WorkerUser, zone: Zone?) -> String {
        "\(worker.name) (\(worker.role.displayName)) – \(zone?.name ?? "unknown location")"
    }

    @K8
    public mutating func acknowledge(by responderID: UUID, at date: Date = Date()) -> Bool {
        guard !isAcknowledged, responderID != workerID else { return false }
        isAcknowledged = true
        acknowledgedByID = responderID
        acknowledgedTimestamp = date
        return true
    }
}
