import Foundation

@K17 @L10
public enum SupplyRequestStatus: Codable, Hashable, Sendable {
    case pending
    case approved
    case rejected
}

@K17
public enum SupplyUrgency: String, Codable, CaseIterable, Sendable {
    case outOfStock
    case runningLow
}

@L10
public struct SupplyItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var category: String
    public var quantity: Double
    public var unit: String
    public var minimumQuantity: Double
    public var restriction: String?
    public var note: String?
    
    public init(id: UUID = UUID(), name: String, category: String, quantity: Double, unit: String, minimumQuantity: Double, restriction: String? = nil, note: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.minimumQuantity = minimumQuantity
        self.restriction = restriction
        self.note = note
    }
}

@K17 @L10
public struct SupplyRequest: Identifiable, Codable, Hashable {
    public let id: UUID
    public let workerID: UUID
    public let itemID: UUID
    public var quantity: Double
    public var requestDate: Date
    public var status: SupplyRequestStatus
    public var note: String?
    public var urgency: SupplyUrgency
    public var zoneID: UUID?

    public init(id: UUID = UUID(), workerID: UUID, itemID: UUID, quantity: Double, requestDate: Date = Date(),
                status: SupplyRequestStatus = .pending, note: String? = nil, urgency: SupplyUrgency = .runningLow,
                zoneID: UUID? = nil) {
        self.id = id
        self.workerID = workerID
        self.itemID = itemID
        self.quantity = quantity
        self.requestDate = requestDate
        self.status = status
        self.note = note
        self.urgency = urgency
        self.zoneID = zoneID
    }

    private enum CodingKeys: String, CodingKey {
        case id, workerID, itemID, quantity, requestDate, status, note, urgency, zoneID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        workerID = try container.decode(UUID.self, forKey: .workerID)
        itemID = try container.decode(UUID.self, forKey: .itemID)
        quantity = try container.decode(Double.self, forKey: .quantity)
        requestDate = try container.decode(Date.self, forKey: .requestDate)
        status = try container.decode(SupplyRequestStatus.self, forKey: .status)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        urgency = try container.decodeIfPresent(SupplyUrgency.self, forKey: .urgency) ?? .runningLow
        zoneID = try container.decodeIfPresent(UUID.self, forKey: .zoneID)
    }
}
