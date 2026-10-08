import Foundation
import Vapor
import AdminCore

@L1 @L2 @L3 @L5 @L6 @N3
public func configure(_ app: Application, backend: LocalAdminBackend) {
    app.middleware.use(AdminErrorMiddleware())

    func session(_ request: Request) async throws -> AdminSession {
        guard let token = request.headers.bearerAuthorization?.token else { throw AdminBackendError.unauthorized }
        return try await backend.session(forToken: token)
    }

    func decode<T: Decodable>(_ type: T.Type, from request: Request) throws -> T {
        do {
            return try request.content.decode(type)
        } catch {
            throw Abort(.badRequest, reason: "Invalid request body")
        }
    }

    app.get("status") { _ async throws -> AdminSnapshot in
        try await backend.snapshot(session: nil)
    }

    app.get("directory") { request async throws -> AdminSnapshot in
        try await backend.snapshot(session: session(request))
    }

    app.post("setup") { request async throws -> AdminSession in
        let body = try decode(AdminAPI.SetupRequest.self, from: request)
        return try await backend.setUpOwner(name: body.name, username: body.username, password: body.password)
    }

    app.post("sessions") { request async throws -> AdminSession in
        let body = try decode(AdminAPI.SignInRequest.self, from: request)
        return try await backend.signIn(username: body.username, password: body.password)
    }

    app.post("sessions", "apple") { request async throws -> AdminSession in
        let body = try decode(AdminAPI.AppleSignInRequest.self, from: request)
        return try await backend.signInWithApple(appleID: body.appleID, email: body.email)
    }

    app.delete("sessions") { request async throws -> AdminAPI.Empty in
        await backend.signOut(session: try session(request))
        return AdminAPI.Empty()
    }

    app.put("me", "password") { request async throws -> AdminSession in
        let body = try decode(AdminAPI.PasswordRequest.self, from: request)
        return try await backend.chooseNewPassword(body.password, session: session(request))
    }

    app.post("me", "password", "change") { request async throws -> AdminAPI.Empty in
        let body = try decode(AdminAPI.ChangePasswordRequest.self, from: request)
        try await backend.changeOwnPassword(current: body.current, new: body.new, session: session(request))
        return AdminAPI.Empty()
    }

    app.post("admins") { request async throws -> AdminAPI.Empty in
        let body = try decode(AdminAPI.AddAdminRequest.self, from: request)
        try await backend.addAdmin(name: body.name, username: body.username, role: body.role,
                                   temporaryPassword: body.temporaryPassword, session: session(request))
        return AdminAPI.Empty()
    }

    app.delete("admins", ":id") { request async throws -> AdminAPI.Empty in
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        try await backend.removeAdmin(id: id, session: session(request))
        return AdminAPI.Empty()
    }

    app.put("admins", ":id", "password") { request async throws -> AdminAPI.Empty in
        guard let id = request.parameters.get("id", as: UUID.self) else { throw Abort(.badRequest) }
        let body = try decode(AdminAPI.PasswordRequest.self, from: request)
        try await backend.resetPassword(of: id, to: body.password, session: session(request))
        return AdminAPI.Empty()
    }

    app.put("settings", "domain") { request async throws -> AdminAPI.Empty in
        let body = try decode(AdminAPI.DomainRequest.self, from: request)
        try await backend.setCompanyDomain(body.domain, session: session(request))
        return AdminAPI.Empty()
    }

    app.put("settings", "features", ":feature") { request async throws -> AdminAPI.Empty in
        guard let raw = request.parameters.get("feature"), let feature = WorkerFeature(rawValue: raw) else {
            throw Abort(.notFound)
        }
        let body = try decode(AdminAPI.FeatureRequest.self, from: request)
        try await backend.setWorkerFeature(feature, enabled: body.enabled, session: session(request))
        return AdminAPI.Empty()
    }
}
