import Foundation
import XCTVapor
import AdminCore
@testable import App

@L1 @L3 @L5 @L6 @N3
final class AuthServiceTests: XCTestCase {
    private var app: Application!
    private var dataFile: URL!

    override func setUp() async throws {
        dataFile = FileManager.default.temporaryDirectory.appendingPathComponent("auth-\(UUID().uuidString).json")
        app = try await Application.make(.testing)
        configure(app, backend: LocalAdminBackend(store: FileDirectoryStore(fileURL: dataFile), hasher: BcryptPasswordHasher()))
    }

    override func tearDown() async throws {
        try await app.asyncShutdown()
        try? FileManager.default.removeItem(at: dataFile)
    }

    private func setUpOwner() async throws -> AdminSession {
        var session: AdminSession?
        try await app.test(.POST, "setup", beforeRequest: { request in
            try request.content.encode(AdminAPI.SetupRequest(name: "Kiss Anna", username: "anna", password: "Secret-123"))
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            session = try response.content.decode(AdminSession.self)
        })
        return try XCTUnwrap(session)
    }

    func testStatusBeforeSetup() async throws {
        try await app.test(.GET, "status") { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertFalse(try response.content.decode(AdminSnapshot.self).isSetUp)
        }
    }

    func testDirectoryNeedsAToken() async throws {
        _ = try await setUpOwner()
        try await app.test(.GET, "directory") { response async throws in
            XCTAssertEqual(response.status, .unauthorized)
            XCTAssertEqual(try response.content.decode(AdminBackendError.self), .unauthorized)
        }
    }

    func testWrongPasswordIsUnauthorizedWithAJSONError() async throws {
        _ = try await setUpOwner()
        try await app.test(.POST, "sessions", beforeRequest: { request in
            try request.content.encode(AdminAPI.SignInRequest(username: "anna", password: "wrong-pass"))
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .unauthorized)
            XCTAssertEqual(try response.content.decode(AdminBackendError.self), .directory(.invalidCredentials))
        })
    }

    func testPasswordsAreStoredAsBcryptHashes() async throws {
        _ = try await setUpOwner()
        let saved = try String(contentsOf: dataFile, encoding: .utf8)
        XCTAssertFalse(saved.contains("Secret-123"))
        let directory = try JSONDecoder().decode(AdminDirectory.self, from: Data(contentsOf: dataFile))
        let hash = String(decoding: try XCTUnwrap(directory.credential(for: directory.admins[0].id)).hash, as: UTF8.self)
        XCTAssertTrue(hash.hasPrefix("$2b$"))
    }

    func testRemoteClientAgainstARunningServer() async throws {
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 0
        try await app.server.start()
        let port = try XCTUnwrap(app.http.server.shared.localAddress?.port)
        let client = RemoteAdminBackend(baseURL: URL(string: "http://127.0.0.1:\(port)")!)

        let before = try await client.snapshot(session: nil)
        XCTAssertFalse(before.isSetUp)

        let owner = try await client.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        try await client.setCompanyDomain("clubneon.hu", session: owner)
        try await client.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                  temporaryPassword: "Temp-1234", session: owner)

        let temporary = try await client.signIn(username: "bela", password: "Temp-1234")
        XCTAssertTrue(temporary.mustChangePassword)
        do {
            _ = try await client.snapshot(session: temporary)
            XCTFail("A temporary session must not read the directory")
        } catch let error as AdminBackendError {
            XCTAssertEqual(error, .passwordChangeRequired)
        }
        let bela = try await client.chooseNewPassword("Bela-5678", session: temporary)
        XCTAssertFalse(bela.mustChangePassword)

        do {
            try await client.addAdmin(name: "Tóth Cili", username: "cili", role: .userAdmin,
                                      temporaryPassword: "Temp-1234", session: bela)
            XCTFail("A business manager must not add administrators")
        } catch let error as AdminBackendError {
            XCTAssertEqual(error, .directory(.notPermitted))
        }

        try await client.setWorkerFeature(.guide, enabled: false, session: owner)
        let snapshot = try await client.snapshot(session: owner)
        XCTAssertEqual(snapshot.admins.map(\.username), ["anna", "bela"])
        XCTAssertEqual(snapshot.companyDomain, "clubneon.hu")
        XCTAssertFalse(snapshot.enabledWorkerFeatures.contains(.guide))

        await client.signOut(session: owner)
        do {
            _ = try await client.snapshot(session: owner)
            XCTFail("A signed-out session must not work")
        } catch let error as AdminBackendError {
            XCTAssertEqual(error, .unauthorized)
        }
        await app.server.shutdown()
    }
}
