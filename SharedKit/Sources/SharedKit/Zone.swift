import Foundation

@L7 @K16
public struct Zone: Identifiable, Codable, Hashable {
    public static let qrPrefix = "nightlife://zone/"

    public let id: UUID
    public var floorID: UUID?
    public var name: String
    public var outline: [PlanPoint]

    public var qrPayload: String { Zone.qrPrefix + id.uuidString }
    public var area: Double { PlanGeometry.area(of: outline) }
    public var center: PlanPoint { PlanGeometry.centroid(of: outline) }

    public init(id: UUID = UUID(), floorID: UUID? = nil, name: String, outline: [PlanPoint] = []) {
        self.id = id
        self.floorID = floorID
        self.name = name
        self.outline = outline
    }

    private enum CodingKeys: String, CodingKey {
        case id, floorID, name, outline, cells
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        floorID = try container.decodeIfPresent(UUID.self, forKey: .floorID)
        name = try container.decode(String.self, forKey: .name)
        outline = try container.decodeIfPresent([PlanPoint].self, forKey: .outline)
            ?? LegacyGridCell.outline(of: container.decodeIfPresent([LegacyGridCell].self, forKey: .cells) ?? [])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(floorID, forKey: .floorID)
        try container.encode(name, forKey: .name)
        try container.encode(outline, forKey: .outline)
    }

    public static func zoneID(fromQRPayload payload: String) -> UUID? {
        guard payload.hasPrefix(qrPrefix) else { return nil }
        return UUID(uuidString: String(payload.dropFirst(qrPrefix.count)))
    }
}

@K16
public struct ZoneCheckIn: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public let zoneID: UUID
    public let timestamp: Date

    public init(id: UUID = UUID(), workerID: UUID, zoneID: UUID, timestamp: Date = Date()) {
        self.id = id
        self.workerID = workerID
        self.zoneID = zoneID
        self.timestamp = timestamp
    }
}

@K16 @N4
public struct WorkerPosition {
    public enum CheckInError: Error, Equatable {
        case invalidCode
        case notOnShift
    }

    public let workerID: UUID
    public private(set) var isOnShift: Bool
    public private(set) var currentZoneID: UUID?
    public private(set) var checkIns: [ZoneCheckIn] = []

    public init(workerID: UUID, isOnShift: Bool) {
        self.workerID = workerID
        self.isOnShift = isOnShift
    }

    public mutating func checkIn(scanning payload: String, knownZoneIDs: Set<UUID>, at date: Date = Date()) throws {
        guard isOnShift else { throw CheckInError.notOnShift }
        guard let zoneID = Zone.zoneID(fromQRPayload: payload), knownZoneIDs.contains(zoneID) else {
            throw CheckInError.invalidCode
        }
        currentZoneID = zoneID
        checkIns.append(ZoneCheckIn(workerID: workerID, zoneID: zoneID, timestamp: date))
    }

    public mutating func endShift() {
        isOnShift = false
        currentZoneID = nil
    }
}

extension ZoneCheckIn {
    @K6 @L4
    public static func latestZones(from checkIns: [ZoneCheckIn]) -> [UUID: UUID] {
        var latest: [UUID: ZoneCheckIn] = [:]
        for checkIn in checkIns where latest[checkIn.workerID].map({ $0.timestamp < checkIn.timestamp }) ?? true {
            latest[checkIn.workerID] = checkIn
        }
        return latest.mapValues(\.zoneID)
    }
}
