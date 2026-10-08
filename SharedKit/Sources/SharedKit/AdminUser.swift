import Foundation

@L1 @L3
public enum AdminRole: Codable {
    case userAdmin
    case businessManager
    case owner
}

@L1
public enum SignInMethod: Codable, Equatable {
    case apple
    case password
}

@L1 @L3
public struct AdminUser: Identifiable, Codable {
    public let id: UUID
    public let email: String
    public var name: String
    public var profileImageURL: URL?
    public var role: AdminRole
    public var signInMethod: SignInMethod
    
    public init(id: UUID = UUID(), email: String, name: String, profileImageURL: URL? = nil, role: AdminRole, signInMethod: SignInMethod = .apple) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
        self.role = role
        self.signInMethod = signInMethod
    }
}
