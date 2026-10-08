import Foundation
import Vapor
import AdminCore

@L1 @N3
public struct BcryptPasswordHasher: PasswordHashing {
    public init() {}

    public func makeSalt() -> Data {
        Data()
    }

    public func hash(_ password: String, salt: Data) -> Data {
        Data(((try? Bcrypt.hash(password)) ?? "").utf8)
    }

    public func verify(_ password: String, hash: Data, salt: Data) -> Bool {
        (try? Bcrypt.verify(password, created: String(decoding: hash, as: UTF8.self))) ?? false
    }
}

@L1 @L3
public struct FileDirectoryStore: AdminDirectoryPersisting {
    private let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() -> AdminDirectory? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(AdminDirectory.self, from: data)
    }

    public func save(_ directory: AdminDirectory) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(directory).write(to: fileURL, options: .atomic)
    }
}

extension AdminSnapshot: @retroactive Content {}
extension AdminSession: @retroactive Content {}
extension AdminAPI.Empty: @retroactive Content {}
extension AdminAPI.SetupRequest: @retroactive Content {}
extension AdminAPI.SignInRequest: @retroactive Content {}
extension AdminAPI.AppleSignInRequest: @retroactive Content {}
extension AdminAPI.PasswordRequest: @retroactive Content {}
extension AdminAPI.ChangePasswordRequest: @retroactive Content {}
extension AdminAPI.AddAdminRequest: @retroactive Content {}
extension AdminAPI.DomainRequest: @retroactive Content {}
extension AdminAPI.FeatureRequest: @retroactive Content {}

@L1 @N3
struct AdminErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as AdminBackendError {
            let response = Response(status: Self.status(for: error))
            try response.content.encode(error, as: .json)
            return response
        }
    }

    static func status(for error: AdminBackendError) -> HTTPResponseStatus {
        switch error {
        case .unauthorized: return .unauthorized
        case .passwordChangeRequired: return .forbidden
        case .unavailable: return .serviceUnavailable
        case .directory(let directoryError):
            switch directoryError {
            case .invalidCredentials: return .unauthorized
            case .notPermitted: return .forbidden
            case .unknownAdmin: return .notFound
            case .duplicateUsername, .alreadySetUp, .lastOwner: return .conflict
            default: return .badRequest
            }
        }
    }
}
