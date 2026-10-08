import Foundation
import Testing
import Requirements
@testable import AdminCore

final class MemoryDirectoryStore: AdminDirectoryPersisting, @unchecked Sendable {
    private(set) var saved: AdminDirectory?
    private(set) var saveCount = 0

    init(_ directory: AdminDirectory? = nil) {
        saved = directory
    }

    func load() -> AdminDirectory? { saved }

    func save(_ directory: AdminDirectory) throws {
        saved = directory
        saveCount += 1
    }
}

final class TestClock: @unchecked Sendable {
    var now = Date(timeIntervalSince1970: 1_800_000_000)
}

@Suite("LocalAdminBackend")
@L1 @L3 @L5 @N3
struct LocalAdminBackendTests {

    private func backend(store: MemoryDirectoryStore = MemoryDirectoryStore(), clock: TestClock = TestClock()) -> LocalAdminBackend {
        LocalAdminBackend(store: store, hasher: TestPasswordHasher(), sessionLifetime: 3600, now: { clock.now })
    }

    @Test func beforeSetupTheSnapshotSaysSo() async throws {
        let snapshot = try await backend().snapshot(session: nil)
        #expect(!snapshot.isSetUp)
    }

    @Test func setupReturnsASessionAndListsAdmins() async throws {
        let backend = backend()
        let session = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        #expect(session.admin.role == .owner)
        #expect(!session.token.isEmpty)
        let snapshot = try await backend.snapshot(session: session)
        #expect(snapshot.admins.map(\.username) == ["anna"])
    }

    @Test func withoutSessionOnlyPublicInformationIsShared() async throws {
        let backend = backend()
        let session = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        try await backend.setCompanyDomain("clubneon.hu", session: session)
        let snapshot = try await backend.snapshot(session: nil)
        #expect(snapshot.isSetUp)
        #expect(snapshot.companyDomain == "clubneon.hu")
        #expect(snapshot.admins.isEmpty)
    }

    @Test func wrongPasswordIsRejected() async throws {
        let backend = backend()
        _ = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        await #expect(throws: AdminBackendError.directory(.invalidCredentials)) {
            try await backend.signIn(username: "anna", password: "wrong-pass")
        }
    }

    @Test func unknownTokenIsUnauthorized() async throws {
        let backend = backend()
        let session = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        let forged = AdminSession(token: "forged", admin: session.admin, mustChangePassword: false)
        await #expect(throws: AdminBackendError.unauthorized) {
            try await backend.snapshot(session: forged)
        }
    }

    @Test func temporaryPasswordSessionCanOnlyChangeThePassword() async throws {
        let backend = backend()
        let owner = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        try await backend.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                   temporaryPassword: "Temp-1234", session: owner)
        let bela = try await backend.signIn(username: "bela", password: "Temp-1234")
        #expect(bela.mustChangePassword)
        await #expect(throws: AdminBackendError.passwordChangeRequired) {
            try await backend.snapshot(session: bela)
        }
        let changed = try await backend.chooseNewPassword("Bela-5678", session: bela)
        #expect(!changed.mustChangePassword)
        #expect(try await backend.snapshot(session: changed).admins.count == 2)
    }

    @Test func signOutInvalidatesTheToken() async throws {
        let backend = backend()
        let session = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        await backend.signOut(session: session)
        await #expect(throws: AdminBackendError.unauthorized) {
            try await backend.snapshot(session: session)
        }
    }

    @Test func sessionsExpire() async throws {
        let clock = TestClock()
        let backend = backend(clock: clock)
        let session = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        clock.now = clock.now.addingTimeInterval(3601)
        await #expect(throws: AdminBackendError.unauthorized) {
            try await backend.snapshot(session: session)
        }
    }

    @Test func changesArePersistedAndReloaded() async throws {
        let store = MemoryDirectoryStore()
        let first = backend(store: store)
        let owner = try await first.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        try await first.setWorkerFeature(.guide, enabled: false, session: owner)
        #expect(store.saveCount == 2)
        let second = backend(store: store)
        let session = try await second.signIn(username: "anna", password: "Secret-123")
        #expect(try await second.snapshot(session: session).enabledWorkerFeatures.contains(.guide) == false)
    }

    @Test func permissionsComeFromTheSessionsAdmin() async throws {
        let backend = backend()
        let owner = try await backend.setUpOwner(name: "Kiss Anna", username: "anna", password: "Secret-123")
        try await backend.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                   temporaryPassword: "Temp-1234", session: owner)
        let temporary = try await backend.signIn(username: "bela", password: "Temp-1234")
        let bela = try await backend.chooseNewPassword("Bela-5678", session: temporary)
        await #expect(throws: AdminBackendError.directory(.notPermitted)) {
            try await backend.addAdmin(name: "Tóth Cili", username: "cili", role: .userAdmin,
                                       temporaryPassword: "Temp-1234", session: bela)
        }
    }

    @Test func errorsRoundTripThroughJSON() throws {
        let errors: [AdminBackendError] = [.unauthorized, .passwordChangeRequired, .directory(.duplicateUsername("anna"))]
        let decoded = try JSONDecoder().decode([AdminBackendError].self, from: JSONEncoder().encode(errors))
        #expect(decoded == errors)
    }
}
