import Foundation
import CommonCrypto
import Security

@L1 @N3
public protocol PasswordHashing {
    func makeSalt() -> Data
    func hash(_ password: String, salt: Data) -> Data
}

@L1 @N3
public struct PBKDF2PasswordHasher: PasswordHashing {
    public let iterations: UInt32

    public init(iterations: UInt32 = 600_000) {
        self.iterations = iterations
    }

    public func makeSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
    }

    public func hash(_ password: String, salt: Data) -> Data {
        var derived = [UInt8](repeating: 0, count: 32)
        let saltBytes = [UInt8](salt)
        _ = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, password.utf8.count,
                                 saltBytes, saltBytes.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                                 iterations, &derived, derived.count)
        return Data(derived)
    }
}

@L1 @N3
public struct AdminCredential: Codable, Hashable {
    public let adminID: UUID
    public var salt: Data
    public var hash: Data
    public var mustChangePassword: Bool
}

@L1 @L3 @L6 @N3
public struct AdminDirectory: Codable, Hashable {
    public enum DirectoryError: Error, Equatable {
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
    }

    public struct SignInResult: Equatable {
        public let admin: AdminUser
        public let mustChangePassword: Bool
    }

    public static let minimumPasswordLength = 8

    public private(set) var admins: [AdminUser] = []
    private var credentials: [AdminCredential] = []
    public private(set) var companyDomain = ""

    public init() {}

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
              Self.constantTimeEqual(hasher.hash(password, salt: credential.salt), credential.hash) else {
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

    private static func constantTimeEqual(_ lhs: Data, _ rhs: Data) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }
}
