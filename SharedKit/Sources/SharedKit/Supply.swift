import Foundation

@K17 @L10
public enum SupplyRequestStatus: Codable {
    case pending
    case approved
    case rejected
}

@L10
public struct SupplyItem: Identifiable, Codable {
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
public struct SupplyRequest: Identifiable, Codable {
    public let id: UUID
    public let workerID: UUID
    public let itemID: UUID
    public var quantity: Double
    public var requestDate: Date
    public var status: SupplyRequestStatus
    public var note: String?
    
    public init(id: UUID = UUID(), workerID: UUID, itemID: UUID, quantity: Double, requestDate: Date = Date(), status: SupplyRequestStatus = .pending, note: String? = nil) {
        self.id = id
        self.workerID = workerID
        self.itemID = itemID
        self.quantity = quantity
        self.requestDate = requestDate
        self.status = status
        self.note = note
    }
}
