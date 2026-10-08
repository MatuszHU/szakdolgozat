import Foundation

@L1 @L3
public enum AdminRole: Codable, Hashable, Sendable {
    case userAdmin
    case businessManager
    case owner

    @L3
    public var displayName: String {
        switch self {
        case .userAdmin: return "user admin"
        case .businessManager: return "business manager"
        case .owner: return "owner"
        }
    }

    @L3 @N3
    public var canManageAdmins: Bool {
        self == .owner || self == .userAdmin
    }
}

@L1
public enum SignInMethod: Codable, Equatable {
    case apple
    case password
}

@L1 @L3
public struct AdminUser: Identifiable, Codable, Hashable {
    public let id: UUID
    public var username: String
    public var name: String
    public var profileImageURL: URL?
    public var role: AdminRole
    public var signInMethod: SignInMethod
    public var appleID: String?

    public init(id: UUID = UUID(), username: String, name: String, profileImageURL: URL? = nil, role: AdminRole,
                signInMethod: SignInMethod = .apple, appleID: String? = nil) {
        self.id = id
        self.username = username
        self.name = name
        self.profileImageURL = profileImageURL
        self.role = role
        self.signInMethod = signInMethod
        self.appleID = appleID
    }
}
