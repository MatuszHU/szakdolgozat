import Foundation
import Testing
import Requirements
@testable import AdminCore

@Suite("Company settings")
@L6 @L1
struct CompanySettingsTests {

    private let hasher = TestPasswordHasher()

    private func directory() throws -> (AdminDirectory, AdminUser) {
        var directory = AdminDirectory()
        let owner = try directory.createOwner(name: "Kiss Anna", username: "anna", password: "Secret-123", hasher: hasher)
        return (directory, owner)
    }

    @Test func allWorkerFeaturesAreOnByDefault() {
        #expect(AdminDirectory().enabledWorkerFeatures == Set(WorkerFeature.allCases))
    }

    @Test func featureNamesAndRequirements() {
        #expect(WorkerFeature.allCases.map(\.displayName) == ["profile picture", "statistics", "guide", "supply requests"])
    }

    @Test func anyAdministratorCanSwitchFeatures() throws {
        var (directory, owner) = try directory()
        let manager = try directory.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                             temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        try directory.setWorkerFeature(.supplyRequests, enabled: false, by: manager.id)
        #expect(!directory.enabledWorkerFeatures.contains(.supplyRequests))
        try directory.setWorkerFeature(.supplyRequests, enabled: true, by: owner.id)
        #expect(directory.enabledWorkerFeatures.contains(.supplyRequests))
    }

    @Test func unknownAdministratorCannotSwitchFeatures() throws {
        var (directory, _) = try directory()
        #expect(throws: AdminDirectory.DirectoryError.notPermitted) {
            try directory.setWorkerFeature(.guide, enabled: false, by: UUID())
        }
    }

    @Test func changeOwnPasswordNeedsTheCurrentOne() throws {
        var (directory, owner) = try directory()
        #expect(throws: AdminDirectory.DirectoryError.wrongCurrentPassword) {
            try directory.changeOwnPassword(of: owner.id, current: "wrong-pass", new: "Better-456", hasher: hasher)
        }
        try directory.changeOwnPassword(of: owner.id, current: "Secret-123", new: "Better-456", hasher: hasher)
        #expect(throws: Never.self) { try directory.signIn(username: "anna", password: "Better-456", hasher: hasher) }
    }

    @Test func olderSavedDirectoriesStillLoad() throws {
        var (directory, _) = try directory()
        try directory.setWorkerFeature(.guide, enabled: false, by: directory.admins[0].id)
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(directory)) as! [String: Any]
        json.removeValue(forKey: "enabledWorkerFeatures")
        let decoded = try JSONDecoder().decode(AdminDirectory.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(decoded.admins.map(\.username) == ["anna"])
        #expect(decoded.enabledWorkerFeatures == Set(WorkerFeature.allCases))
    }
}
