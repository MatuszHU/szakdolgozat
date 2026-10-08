import Foundation
import Combine
import SharedKit

@L1 @L3
protocol AdminDirectoryStoring {
    func load() -> AdminDirectory?
    func save(_ directory: AdminDirectory) throws
}

@L1 @L2 @L3 @L5 @L6
class AdminSessionViewModel: ObservableObject {
    enum Screen: Equatable {
        case setup
        case signIn
        case changePassword
        case main
    }

    @Published private(set) var directory: AdminDirectory
    @Published private(set) var screen: Screen
    @Published private(set) var currentAdmin: AdminUser?
    @Published private(set) var errorMessage: String?
    private let store: AdminDirectoryStoring
    private let hasher: PasswordHashing

    init(directory: AdminDirectory, store: AdminDirectoryStoring, hasher: PasswordHashing) {
        self.directory = directory
        self.store = store
        self.hasher = hasher
        screen = directory.isSetUp ? .signIn : .setup
    }

    func email(of admin: AdminUser) -> String {
        directory.email(of: admin)
    }

    func setUpOwner(name: String, username: String, password: String) {
        var created: AdminUser?
        apply { created = try $0.createOwner(name: name, username: username, password: password, hasher: hasher) }
        if let created { open(created) }
    }

    func signIn(username: String, password: String) {
        do {
            let result = try directory.signIn(username: username, password: password, hasher: hasher)
            currentAdmin = result.admin
            errorMessage = nil
            screen = result.mustChangePassword ? .changePassword : .main
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    func signInWithApple(appleID: String, email: String?) {
        var admin: AdminUser?
        apply { admin = try $0.signInWithApple(appleID: appleID, email: email) }
        if let admin { open(admin) }
    }

    func chooseNewPassword(_ password: String) {
        guard let adminID = currentAdmin?.id else { return }
        apply { try $0.changePassword(of: adminID, to: password, hasher: hasher) }
        if errorMessage == nil { screen = .main }
    }

    func signOut() {
        currentAdmin = nil
        errorMessage = nil
        screen = directory.isSetUp ? .signIn : .setup
    }

    func addAdmin(name: String, username: String, role: AdminRole, temporaryPassword: String?) {
        guard let actorID = currentAdmin?.id else { return }
        apply {
            try $0.addAdmin(name: name, username: username, role: role, temporaryPassword: temporaryPassword,
                            by: actorID, hasher: hasher)
        }
    }

    func removeAdmin(id: UUID) {
        guard let actorID = currentAdmin?.id else { return }
        apply { try $0.removeAdmin(id: id, by: actorID) }
    }

    func resetPassword(of adminID: UUID, to temporaryPassword: String) {
        guard let actorID = currentAdmin?.id else { return }
        apply { try $0.resetPassword(of: adminID, to: temporaryPassword, by: actorID, hasher: hasher) }
    }

    func setCompanyDomain(_ domain: String) {
        guard let actorID = currentAdmin?.id else { return }
        apply { try $0.setCompanyDomain(domain, by: actorID) }
    }

    @L6
    func setWorkerFeature(_ feature: WorkerFeature, enabled: Bool) {
        guard let actorID = currentAdmin?.id else { return }
        apply { try $0.setWorkerFeature(feature, enabled: enabled, by: actorID) }
    }

    @L6 @L1
    func changeOwnPassword(current: String, new newPassword: String) {
        guard let adminID = currentAdmin?.id else { return }
        apply { try $0.changeOwnPassword(of: adminID, current: current, new: newPassword, hasher: hasher) }
    }

    private func open(_ admin: AdminUser) {
        currentAdmin = admin
        screen = .main
    }

    private func apply(_ edit: (inout AdminDirectory) throws -> Void) {
        var edited = directory
        do {
            try edit(&edited)
            directory = edited
            errorMessage = nil
            try store.save(edited)
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    private static func message(for error: Error) -> String {
        switch error as? AdminDirectory.DirectoryError {
        case .alreadySetUp: return "The owner has already been set up"
        case .emptyName: return "A name is required"
        case .invalidUsername: return "The username may contain lowercase letters, digits, dots, dashes and underscores"
        case .duplicateUsername(let username): return "The username \(username) is already taken"
        case .weakPassword: return "The password must be at least \(AdminDirectory.minimumPasswordLength) characters long"
        case .invalidCredentials: return "Wrong username or password"
        case .notPermitted: return "You are not allowed to manage administrators"
        case .unknownAdmin: return "The administrator no longer exists"
        case .lastOwner: return "The last owner cannot be removed"
        case .invalidDomain: return "The domain is not valid"
        case .wrongSignInMethod: return "This administrator signs in with Apple"
        case .wrongCurrentPassword: return "The current password is wrong"
        case nil: return "The administrators could not be saved"
        }
    }
}
