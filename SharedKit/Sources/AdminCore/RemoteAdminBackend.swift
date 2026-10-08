import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Requirements

@L1 @N3
public enum AdminAPI {
    public struct SetupRequest: Codable, Sendable {
        public let name: String
        public let username: String
        public let password: String

        public init(name: String, username: String, password: String) {
            self.name = name
            self.username = username
            self.password = password
        }
    }

    public struct SignInRequest: Codable, Sendable {
        public let username: String
        public let password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }

    public struct AppleSignInRequest: Codable, Sendable {
        public let appleID: String
        public let email: String?

        public init(appleID: String, email: String?) {
            self.appleID = appleID
            self.email = email
        }
    }

    public struct PasswordRequest: Codable, Sendable {
        public let password: String

        public init(password: String) {
            self.password = password
        }
    }

    public struct ChangePasswordRequest: Codable, Sendable {
        public let current: String
        public let new: String

        public init(current: String, new: String) {
            self.current = current
            self.new = new
        }
    }

    public struct AddAdminRequest: Codable, Sendable {
        public let name: String
        public let username: String
        public let role: AdminRole
        public let temporaryPassword: String?

        public init(name: String, username: String, role: AdminRole, temporaryPassword: String?) {
            self.name = name
            self.username = username
            self.role = role
            self.temporaryPassword = temporaryPassword
        }
    }

    public struct DomainRequest: Codable, Sendable {
        public let domain: String

        public init(domain: String) {
            self.domain = domain
        }
    }

    public struct FeatureRequest: Codable, Sendable {
        public let enabled: Bool

        public init(enabled: Bool) {
            self.enabled = enabled
        }
    }

    public struct Empty: Codable, Sendable {
        public init() {}
    }
}

@L1 @L2 @L3 @L5 @L6 @N3
public struct RemoteAdminBackend: AdminBackend {
    private let baseURL: URL
    private let urlSession: URLSession

    public init(baseURL: URL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    public func snapshot(session: AdminSession?) async throws -> AdminSnapshot {
        try await send("GET", session == nil ? "status" : "directory", body: AdminAPI.Empty?.none, token: session?.token)
    }

    public func setUpOwner(name: String, username: String, password: String) async throws -> AdminSession {
        try await send("POST", "setup", body: AdminAPI.SetupRequest(name: name, username: username, password: password), token: nil)
    }

    public func signIn(username: String, password: String) async throws -> AdminSession {
        try await send("POST", "sessions", body: AdminAPI.SignInRequest(username: username, password: password), token: nil)
    }

    public func signInWithApple(appleID: String, email: String?) async throws -> AdminSession {
        try await send("POST", "sessions/apple", body: AdminAPI.AppleSignInRequest(appleID: appleID, email: email), token: nil)
    }

    public func chooseNewPassword(_ password: String, session: AdminSession) async throws -> AdminSession {
        try await send("PUT", "me/password", body: AdminAPI.PasswordRequest(password: password), token: session.token)
    }

    public func changeOwnPassword(current: String, new newPassword: String, session: AdminSession) async throws {
        let _: AdminAPI.Empty = try await send("POST", "me/password/change",
                                               body: AdminAPI.ChangePasswordRequest(current: current, new: newPassword),
                                               token: session.token)
    }

    public func addAdmin(name: String, username: String, role: AdminRole, temporaryPassword: String?,
                         session: AdminSession) async throws {
        let _: AdminAPI.Empty = try await send("POST", "admins",
                                               body: AdminAPI.AddAdminRequest(name: name, username: username, role: role,
                                                                              temporaryPassword: temporaryPassword),
                                               token: session.token)
    }

    public func removeAdmin(id: UUID, session: AdminSession) async throws {
        let _: AdminAPI.Empty = try await send("DELETE", "admins/\(id.uuidString)", body: AdminAPI.Empty?.none,
                                               token: session.token)
    }

    public func resetPassword(of adminID: UUID, to temporaryPassword: String, session: AdminSession) async throws {
        let _: AdminAPI.Empty = try await send("PUT", "admins/\(adminID.uuidString)/password",
                                               body: AdminAPI.PasswordRequest(password: temporaryPassword),
                                               token: session.token)
    }

    public func setCompanyDomain(_ domain: String, session: AdminSession) async throws {
        let _: AdminAPI.Empty = try await send("PUT", "settings/domain", body: AdminAPI.DomainRequest(domain: domain),
                                               token: session.token)
    }

    public func setWorkerFeature(_ feature: WorkerFeature, enabled: Bool, session: AdminSession) async throws {
        let _: AdminAPI.Empty = try await send("PUT", "settings/features/\(feature.rawValue)",
                                               body: AdminAPI.FeatureRequest(enabled: enabled), token: session.token)
    }

    public func signOut(session: AdminSession) async {
        let _: AdminAPI.Empty? = try? await send("DELETE", "sessions", body: AdminAPI.Empty?.none, token: session.token)
    }

    private func send<Body: Encodable, Response: Decodable>(_ method: String, _ path: String, body: Body?,
                                                            token: String?) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw AdminBackendError.unavailable("The authentication service cannot be reached")
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            if let error = try? JSONDecoder().decode(AdminBackendError.self, from: data) { throw error }
            throw status == 401 ? AdminBackendError.unauthorized
                                : AdminBackendError.unavailable("The authentication service answered \(status)")
        }
        if Response.self == AdminAPI.Empty.self, data.isEmpty {
            return AdminAPI.Empty() as! Response
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
