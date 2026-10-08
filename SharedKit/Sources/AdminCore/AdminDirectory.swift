import Foundation
import Requirements

@L1 @N3
public protocol PasswordHashing: Sendable {
    func makeSalt() -> Data
    func hash(_ password: String, salt: Data) -> Data
    func verify(_ password: String, hash: Data, salt: Data) -> Bool
}

extension PasswordHashing {
    public func verify(_ password: String, hash expected: Data, salt: Data) -> Bool {
        let actual = hash(password, salt: salt)
        guard actual.count == expected.count else { return false }
        return zip(actual, expected).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}

@L6 @K10 @K12 @K15 @K17
public enum WorkerFeature: String, Codable, CaseIterable, Hashable, Sendable {
    case profilePicture
    case statistics
    case guide
    case supplyRequests

    public var displayName: String {
        switch self {
        case .profilePicture: return "profile picture"
        case .statistics: return "statistics"
        case .guide: return "guide"
        case .supplyRequests: return "supply requests"
        }
    }
}

@L1 @N3
public struct AdminCredential: Codable, Hashable, Sendable {
    public let adminID: UUID
    public var salt: Data
    public var hash: Data
    public var mustChangePassword: Bool
}

@L1 @L3 @L6 @N3
public struct AdminDirectory: Codable, Hashable, Sendable {
    public enum DirectoryError: Error, Equatable, Codable, Sendable {
        case alreadySetUp
        case emptyName
        case invalidUsername
        case duplicateUsername(String)
        case weakPassword
        case invalidCredentials
        case notPermitted
        case unknownAdmin
        case lastOwner
        case invalidDomain
        case wrongSignInMethod
        case wrongCurrentPassword
    }

    public struct SignInResult: Equatable, Sendable {
        public let admin: AdminUser
        public let mustChangePassword: Bool
    }

    public static let minimumPasswordLength = 8

    public private(set) var admins: [AdminUser] = []
    private var credentials: [AdminCredential] = []
    public private(set) var companyDomain = ""
    @L6
    public private(set) var enabledWorkerFeatures = Set(WorkerFeature.allCases)

    private enum CodingKeys: String, CodingKey {
        case admins, credentials, companyDomain, enabledWorkerFeatures
    }

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        admins = try container.decode([AdminUser].self, forKey: .admins)
        credentials = try container.decode([AdminCredential].self, forKey: .credentials)
        companyDomain = try container.decode(String.self, forKey: .companyDomain)
        enabledWorkerFeatures = try container.decodeIfPresent(Set<WorkerFeature>.self, forKey: .enabledWorkerFeatures)
            ?? Set(WorkerFeature.allCases)
    }

    public var isSetUp: Bool { !admins.isEmpty }

    public func credential(for adminID: UUID) -> AdminCredential? {
        credentials.first { $0.adminID == adminID }
    }

    public func email(of admin: AdminUser) -> String {
        companyDomain.isEmpty ? admin.username : "\(admin.username)@\(companyDomain)"
    }

    @discardableResult
    public mutating func createOwner(name: String, username: String, password: String,
                                     hasher: PasswordHashing) throws -> AdminUser {
        guard !isSetUp else { throw DirectoryError.alreadySetUp }
        return try insert(name: name, username: username, role: .owner, password: password,
                          mustChange: false, hasher: hasher)
    }

    @discardableResult
    public mutating func addAdmin(name: String, username: String, role: AdminRole, temporaryPassword: String?,
                                  by actorID: UUID, hasher: PasswordHashing) throws -> AdminUser {
        _ = try permittedActor(actorID, touching: role)
        return try insert(name: name, username: username, role: role, password: temporaryPassword,
                          mustChange: true, hasher: hasher)
    }

    public mutating func removeAdmin(id: UUID, by actorID: UUID) throws {
        guard let target = admins.first(where: { $0.id == id }) else { throw DirectoryError.unknownAdmin }
        _ = try permittedActor(actorID, touching: target.role)
        if target.role == .owner && admins.filter({ $0.role == .owner }).count == 1 {
            throw DirectoryError.lastOwner
        }
        admins.removeAll { $0.id == id }
        credentials.removeAll { $0.adminID == id }
    }

    public func signIn(username: String, password: String, hasher: PasswordHashing) throws -> SignInResult {
        guard let admin = admins.first(where: { $0.username == username.lowercased() }),
              let credential = credential(for: admin.id),
              hasher.verify(password, hash: credential.hash, salt: credential.salt) else {
            throw DirectoryError.invalidCredentials
        }
        return SignInResult(admin: admin, mustChangePassword: credential.mustChangePassword)
    }

    public mutating func signInWithApple(appleID: String, email: String?) throws -> AdminUser {
        if let linked = admins.first(where: { $0.appleID == appleID }) {
            return linked
        }
        guard let email = email?.lowercased(),
              let index = admins.firstIndex(where: {
                  $0.signInMethod == .apple && $0.appleID == nil && self.email(of: $0) == email
              }) else {
            throw DirectoryError.invalidCredentials
        }
        admins[index].appleID = appleID
        return admins[index]
    }

    public mutating func changePassword(of adminID: UUID, to newPassword: String, hasher: PasswordHashing) throws {
        guard let index = credentials.firstIndex(where: { $0.adminID == adminID }) else {
            throw DirectoryError.wrongSignInMethod
        }
        guard newPassword.count >= Self.minimumPasswordLength else { throw DirectoryError.weakPassword }
        let salt = hasher.makeSalt()
        credentials[index] = AdminCredential(adminID: adminID, salt: salt, hash: hasher.hash(newPassword, salt: salt),
                                             mustChangePassword: false)
    }

    public mutating func resetPassword(of adminID: UUID, to temporaryPassword: String, by actorID: UUID,
                                       hasher: PasswordHashing) throws {
        guard let target = admins.first(where: { $0.id == adminID }) else { throw DirectoryError.unknownAdmin }
        _ = try permittedActor(actorID, touching: target.role)
        try changePassword(of: adminID, to: temporaryPassword, hasher: hasher)
        if let index = credentials.firstIndex(where: { $0.adminID == adminID }) {
            credentials[index].mustChangePassword = true
        }
    }

    @L6
    public mutating func setWorkerFeature(_ feature: WorkerFeature, enabled: Bool, by actorID: UUID) throws {
        guard admins.contains(where: { $0.id == actorID }) else { throw DirectoryError.notPermitted }
        if enabled {
            enabledWorkerFeatures.insert(feature)
        } else {
            enabledWorkerFeatures.remove(feature)
        }
    }

    @L6 @L1
    public mutating func changeOwnPassword(of adminID: UUID, current: String, new newPassword: String,
                                           hasher: PasswordHashing) throws {
        guard let admin = admins.first(where: { $0.id == adminID }) else { throw DirectoryError.unknownAdmin }
        guard (try? signIn(username: admin.username, password: current, hasher: hasher)) != nil else {
            throw DirectoryError.wrongCurrentPassword
        }
        try changePassword(of: adminID, to: newPassword, hasher: hasher)
    }

    public mutating func setCompanyDomain(_ domain: String, by actorID: UUID) throws {
        guard admins.first(where: { $0.id == actorID })?.role == .owner else { throw DirectoryError.notPermitted }
        let domain = domain.trimmingCharacters(in: .whitespaces).lowercased()
        guard domain.range(of: #"^[a-z0-9-]+(\.[a-z0-9-]+)+$"#, options: .regularExpression) != nil else {
            throw DirectoryError.invalidDomain
        }
        companyDomain = domain
    }

    private func permittedActor(_ actorID: UUID, touching role: AdminRole) throws -> AdminUser {
        guard let actor = admins.first(where: { $0.id == actorID }), actor.role.canManageAdmins,
              role != .owner || actor.role == .owner else {
            throw DirectoryError.notPermitted
        }
        return actor
    }

    private mutating func insert(name: String, username: String, role: AdminRole, password: String?,
                                 mustChange: Bool, hasher: PasswordHashing) throws -> AdminUser {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw DirectoryError.emptyName }
        guard username.range(of: #"^[a-z0-9._-]+$"#, options: .regularExpression) != nil else {
            throw DirectoryError.invalidUsername
        }
        guard !admins.contains(where: { $0.username == username }) else {
            throw DirectoryError.duplicateUsername(username)
        }
        if let password, password.count < Self.minimumPasswordLength { throw DirectoryError.weakPassword }
        let admin = AdminUser(username: username, name: name, role: role,
                              signInMethod: password == nil ? .apple : .password)
        admins.append(admin)
        if let password {
            let salt = hasher.makeSalt()
            credentials.append(AdminCredential(adminID: admin.id, salt: salt, hash: hasher.hash(password, salt: salt),
                                               mustChangePassword: mustChange))
        }
        return admin
    }
}
