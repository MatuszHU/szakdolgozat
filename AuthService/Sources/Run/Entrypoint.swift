import Foundation
import Vapor
import AdminCore
import App

@main
@L1
enum Entrypoint {
    static func main() async throws {
        var environment = try Environment.detect()
        try LoggingSystem.bootstrap(from: &environment)
        let app = try await Application.make(environment)
        let dataFile = Environment.get("AUTH_DATA_FILE") ?? "data/admins.json"
        let backend = LocalAdminBackend(store: FileDirectoryStore(fileURL: URL(fileURLWithPath: dataFile)),
                                        hasher: BcryptPasswordHasher())
        app.http.server.configuration.hostname = Environment.get("HOST") ?? "127.0.0.1"
        app.http.server.configuration.port = Environment.get("PORT").flatMap(Int.init) ?? 8080
        configure(app, backend: backend)
        do {
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
