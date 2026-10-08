import Foundation
import Combine
import SharedKit

@L1 @L2 @L3 @L5 @L6
@MainActor
class AdminSessionViewModel: ObservableObject {
    enum Screen: Equatable {
        case loading
        case setup
        case signIn
        case changePassword
        case main
    }

    static let serviceURLKey = "AuthServiceURL"

    @Published private(set) var snapshot = AdminSnapshot(isSetUp: false, companyDomain: "", admins: [],
                                                         enabledWorkerFeatures: Set(WorkerFeature.allCases))
    @Published private(set) var screen = Screen.loading
    @Published private(set) var errorMessage: String?
    @Published private(set) var serviceURL: URL?
    private var backend: AdminBackend
    private var session: AdminSession?
    private let makeLocalBackend: () -> AdminBackend

    init(serviceURL: URL? = nil, makeLocalBackend: @escaping () -> AdminBackend) {
        self.serviceURL = serviceURL
        self.makeLocalBackend = makeLocalBackend
        backend = serviceURL.map { RemoteAdminBackend(baseURL: $0) } ?? makeLocalBackend()
    }

    var currentAdmin: AdminUser? { session?.admin }

    func email(of admin: AdminUser) -> String {
        snapshot.companyDomain.isEmpty ? admin.username : "\(admin.username)@\(snapshot.companyDomain)"
    }

    func load() async {
        await run {
            snapshot = try await backend.snapshot(session: nil)
            screen = snapshot.isSetUp ? .signIn : .setup
        }
    }

    func useService(at url: URL?) async {
        serviceURL = url
        backend = url.map { RemoteAdminBackend(baseURL: $0) } ?? makeLocalBackend()
        session = nil
        await load()
    }

    func setUpOwner(name: String, username: String, password: String) async {
        await open { try await backend.setUpOwner(name: name, username: username, password: password) }
    }

    func signIn(username: String, password: String) async {
        await open { try await backend.signIn(username: username, password: password) }
    }

    func signInWithApple(appleID: String, email: String?) async {
        await open { try await backend.signInWithApple(appleID: appleID, email: email) }
    }

    func chooseNewPassword(_ password: String) async {
        guard let current = session else { return }
        await open { try await backend.chooseNewPassword(password, session: current) }
    }

    func signOut() async {
        if let current = session {
            await backend.signOut(session: current)
        }
        session = nil
        errorMessage = nil
        await load()
    }

    func addAdmin(name: String, username: String, role: AdminRole, temporaryPassword: String?) async {
        await change {
            try await backend.addAdmin(name: name, username: username, role: role,
                                       temporaryPassword: temporaryPassword, session: $0)
        }
    }

    func removeAdmin(id: UUID) async {
        await change { try await backend.removeAdmin(id: id, session: $0) }
    }

    func resetPassword(of adminID: UUID, to temporaryPassword: String) async {
        await change { try await backend.resetPassword(of: adminID, to: temporaryPassword, session: $0) }
    }

    func setCompanyDomain(_ domain: String) async {
        await change { try await backend.setCompanyDomain(domain, session: $0) }
    }

    @L6
    func setWorkerFeature(_ feature: WorkerFeature, enabled: Bool) async {
        await change { try await backend.setWorkerFeature(feature, enabled: enabled, session: $0) }
    }

    @L6 @L1
    func changeOwnPassword(current: String, new newPassword: String) async {
        await change { try await backend.changeOwnPassword(current: current, new: newPassword, session: $0) }
    }

    private func open(_ signIn: () async throws -> AdminSession) async {
        await run {
            let opened = try await signIn()
            session = opened
            if opened.mustChangePassword {
                screen = .changePassword
            } else {
                snapshot = try await backend.snapshot(session: opened)
                screen = .main
            }
        }
    }

    private func change(_ action: (AdminSession) async throws -> Void) async {
        guard let current = session else { return }
        await run {
            try await action(current)
            snapshot = try await backend.snapshot(session: current)
        }
    }

    private func run(_ operation: () async throws -> Void) async {
        do {
            try await operation()
            errorMessage = nil
        } catch let error as AdminBackendError {
            if error == .unauthorized && session != nil {
                session = nil
                screen = .signIn
            }
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "Unexpected error"
        }
    }

    private static func message(for error: AdminBackendError) -> String {
        switch error {
        case .unauthorized: return "Your session has expired, please sign in again"
        case .passwordChangeRequired: return "Choose a new password first"
        case .unavailable(let reason): return reason
        case .directory(let directoryError):
            switch directoryError {
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
            }
        }
    }
}
