import Foundation
import Requirements

@L1 @L3 @L6
public struct AdminSnapshot: Codable, Equatable, Sendable {
    public var isSetUp: Bool
    public var companyDomain: String
    public var admins: [AdminUser]
    public var enabledWorkerFeatures: Set<WorkerFeature>

    public init(isSetUp: Bool, companyDomain: String, admins: [AdminUser], enabledWorkerFeatures: Set<WorkerFeature>) {
        self.isSetUp = isSetUp
        self.companyDomain = companyDomain
        self.admins = admins
        self.enabledWorkerFeatures = enabledWorkerFeatures
    }
}

@L1 @L5
public struct AdminSession: Codable, Equatable, Sendable {
    public let token: String
    public let admin: AdminUser
    public let mustChangePassword: Bool

    public init(token: String, admin: AdminUser, mustChangePassword: Bool) {
        self.token = token
        self.admin = admin
        self.mustChangePassword = mustChangePassword
    }
}

@L1 @N3
public enum AdminBackendError: Error, Equatable, Codable, Sendable {
    case unauthorized
    case passwordChangeRequired
    case directory(AdminDirectory.DirectoryError)
    case unavailable(String)
}

@L1 @L3
public protocol AdminDirectoryPersisting: Sendable {
    func load() -> AdminDirectory?
    func save(_ directory: AdminDirectory) throws
}

@L1 @L2 @L3 @L5 @L6
public protocol AdminBackend: Sendable {
    func snapshot(session: AdminSession?) async throws -> AdminSnapshot
    func setUpOwner(name: String, username: String, password: String) async throws -> AdminSession
    func signIn(username: String, password: String) async throws -> AdminSession
    func signInWithApple(appleID: String, email: String?) async throws -> AdminSession
    func chooseNewPassword(_ password: String, session: AdminSession) async throws -> AdminSession
    func changeOwnPassword(current: String, new newPassword: String, session: AdminSession) async throws
    func addAdmin(name: String, username: String, role: AdminRole, temporaryPassword: String?,
                  session: AdminSession) async throws
    func removeAdmin(id: UUID, session: AdminSession) async throws
    func resetPassword(of adminID: UUID, to temporaryPassword: String, session: AdminSession) async throws
    func setCompanyDomain(_ domain: String, session: AdminSession) async throws
    func setWorkerFeature(_ feature: WorkerFeature, enabled: Bool, session: AdminSession) async throws
    func signOut(session: AdminSession) async
}

@L1 @L2 @L3 @L5 @L6 @N3
public actor LocalAdminBackend: AdminBackend {
    private struct Token {
        let adminID: UUID
        var mustChangePassword: Bool
        let expires: Date
    }

    private var directory: AdminDirectory
    private var tokens: [String: Token] = [:]
    private let store: AdminDirectoryPersisting
    private let hasher: PasswordHashing
    private let sessionLifetime: TimeInterval
    private let now: @Sendable () -> Date

    public init(store: AdminDirectoryPersisting, hasher: PasswordHashing, sessionLifetime: TimeInterval = 12 * 3600,
                now: @escaping @Sendable () -> Date = { Date() }) {
        self.store = store
        self.hasher = hasher
        self.sessionLifetime = sessionLifetime
        self.now = now
        directory = store.load() ?? AdminDirectory()
    }

    public func snapshot(session: AdminSession?) throws -> AdminSnapshot {
        let admins = try session.map { try actor(of: $0) }.map { _ in directory.admins } ?? []
        return AdminSnapshot(isSetUp: directory.isSetUp, companyDomain: directory.companyDomain, admins: admins,
                             enabledWorkerFeatures: directory.enabledWorkerFeatures)
    }

    public func setUpOwner(name: String, username: String, password: String) throws -> AdminSession {
        let owner = try edit { try $0.createOwner(name: name, username: username, password: password, hasher: hasher) }
        return issue(for: owner, mustChangePassword: false)
    }

    public func signIn(username: String, password: String) throws -> AdminSession {
        do {
            let result = try directory.signIn(username: username, password: password, hasher: hasher)
            return issue(for: result.admin, mustChangePassword: result.mustChangePassword)
        } catch let error as AdminDirectory.DirectoryError {
            throw AdminBackendError.directory(error)
        }
    }

    public func signInWithApple(appleID: String, email: String?) throws -> AdminSession {
        let admin = try edit { try $0.signInWithApple(appleID: appleID, email: email) }
        return issue(for: admin, mustChangePassword: false)
    }

    public func chooseNewPassword(_ password: String, session: AdminSession) throws -> AdminSession {
        let adminID = try validated(session, allowingPasswordChange: true).adminID
        try edit { try $0.changePassword(of: adminID, to: password, hasher: hasher) }
        tokens[session.token]?.mustChangePassword = false
        return AdminSession(token: session.token, admin: try current(adminID), mustChangePassword: false)
    }

    public func changeOwnPassword(current: String, new newPassword: String, session: AdminSession) throws {
        let adminID = try actor(of: session)
        try edit { try $0.changeOwnPassword(of: adminID, current: current, new: newPassword, hasher: hasher) }
    }

    public func addAdmin(name: String, username: String, role: AdminRole, temporaryPassword: String?,
                         session: AdminSession) throws {
        let actorID = try actor(of: session)
        try edit {
            try $0.addAdmin(name: name, username: username, role: role, temporaryPassword: temporaryPassword,
                            by: actorID, hasher: hasher)
        }
    }

    public func removeAdmin(id: UUID, session: AdminSession) throws {
        let actorID = try actor(of: session)
        try edit { try $0.removeAdmin(id: id, by: actorID) }
        tokens = tokens.filter { $0.value.adminID != id }
    }

    public func resetPassword(of adminID: UUID, to temporaryPassword: String, session: AdminSession) throws {
        let actorID = try actor(of: session)
        try edit { try $0.resetPassword(of: adminID, to: temporaryPassword, by: actorID, hasher: hasher) }
        tokens = tokens.filter { $0.value.adminID != adminID }
    }

    public func setCompanyDomain(_ domain: String, session: AdminSession) throws {
        let actorID = try actor(of: session)
        try edit { try $0.setCompanyDomain(domain, by: actorID) }
    }

    public func setWorkerFeature(_ feature: WorkerFeature, enabled: Bool, session: AdminSession) throws {
        let actorID = try actor(of: session)
        try edit { try $0.setWorkerFeature(feature, enabled: enabled, by: actorID) }
    }

    public func signOut(session: AdminSession) {
        tokens[session.token] = nil
    }

    public func session(forToken token: String) throws -> AdminSession {
        let probe = AdminSession(token: token, admin: AdminUser(username: "", name: "", role: .businessManager),
                                 mustChangePassword: false)
        let valid = try validated(probe, allowingPasswordChange: true)
        return AdminSession(token: token, admin: try current(valid.adminID), mustChangePassword: valid.mustChangePassword)
    }

    private func issue(for admin: AdminUser, mustChangePassword: Bool) -> AdminSession {
        let token = UUID().uuidString + UUID().uuidString
        tokens[token] = Token(adminID: admin.id, mustChangePassword: mustChangePassword,
                              expires: now().addingTimeInterval(sessionLifetime))
        return AdminSession(token: token, admin: admin, mustChangePassword: mustChangePassword)
    }

    private func validated(_ session: AdminSession, allowingPasswordChange: Bool = false) throws -> Token {
        guard let token = tokens[session.token], token.expires > now(),
              directory.admins.contains(where: { $0.id == token.adminID }) else {
            tokens[session.token] = nil
            throw AdminBackendError.unauthorized
        }
        if token.mustChangePassword && !allowingPasswordChange { throw AdminBackendError.passwordChangeRequired }
        return token
    }

    private func actor(of session: AdminSession) throws -> UUID {
        try validated(session).adminID
    }

    private func current(_ adminID: UUID) throws -> AdminUser {
        guard let admin = directory.admins.first(where: { $0.id == adminID }) else { throw AdminBackendError.unauthorized }
        return admin
    }

    @discardableResult
    private func edit<T>(_ change: (inout AdminDirectory) throws -> T) throws -> T {
        var edited = directory
        let result: T
        do {
            result = try change(&edited)
        } catch let error as AdminDirectory.DirectoryError {
            throw AdminBackendError.directory(error)
        }
        do {
            try store.save(edited)
        } catch {
            throw AdminBackendError.unavailable("The administrators could not be saved")
        }
        directory = edited
        return result
    }
}
