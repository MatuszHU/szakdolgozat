import Foundation

@L3 @K8
public enum WorkerRole: Codable, Hashable {
    case bartender
    case security
    case custom(String)

    public var displayName: String {
        switch self {
        case .bartender: return "bartender"
        case .security: return "security"
        case .custom(let name): return name
        }
    }
}

@L3 @K12
public enum PayPeriod: Codable, Hashable {
    case weekly
    case biweekly
    case monthly
    case custom(Int)
}

@L3
public struct WorkerUser: Identifiable, Codable, Hashable {
    public let id: UUID
    public let appleID: String
    public var name: String
    public var profileImageURL: URL?
    public var role: WorkerRole
    public var workedHours: Double
    public var payPeriod: PayPeriod
    
    public init(id: UUID = UUID(), appleID: String, name: String, profileImageURL: URL? = nil, role: WorkerRole, workedHours: Double = 0, payPeriod: PayPeriod) {
        self.id = id
        self.appleID = appleID
        self.name = name
        self.profileImageURL = profileImageURL
        self.role = role
        self.workedHours = workedHours
        self.payPeriod = payPeriod
    }
}
