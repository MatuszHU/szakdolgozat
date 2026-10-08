import Foundation
import Testing
import Requirements
@testable import AdminCore

@Suite("AdminDirectory")
@L1 @L3 @L6 @N3
struct AdminDirectoryTests {

    private let hasher = TestPasswordHasher()

    private func directoryWithOwner() throws -> (AdminDirectory, AdminUser) {
        var directory = AdminDirectory()
        let owner = try directory.createOwner(name: "Kiss Anna", username: "anna", password: "Secret-123", hasher: hasher)
        return (directory, owner)
    }

    @Test func firstOwnerIsCreatedOnlyOnce() throws {
        var (directory, owner) = try directoryWithOwner()
        #expect(owner.role == .owner)
        #expect(directory.isSetUp)
        #expect(throws: AdminDirectory.DirectoryError.alreadySetUp) {
            try directory.createOwner(name: "Other", username: "other", password: "Secret-123", hasher: hasher)
        }
    }

    @Test(arguments: ["", "Anna", "an na", "anna@club.hu", "ä"])
    func usernameMustBeALowercaseLocalPart(_ username: String) {
        var directory = AdminDirectory()
        #expect(throws: AdminDirectory.DirectoryError.invalidUsername) {
            try directory.createOwner(name: "Kiss Anna", username: username, password: "Secret-123", hasher: hasher)
        }
    }

    @Test func passwordMustHaveEightCharacters() {
        var directory = AdminDirectory()
        #expect(throws: AdminDirectory.DirectoryError.weakPassword) {
            try directory.createOwner(name: "Kiss Anna", username: "anna", password: "short", hasher: hasher)
        }
    }

    @Test func passwordsAreStoredOnlyAsSaltedHashes() throws {
        let (directory, owner) = try directoryWithOwner()
        let credential = try #require(directory.credential(for: owner.id))
        #expect(credential.hash != Data("Secret-123".utf8))
        #expect(!credential.salt.isEmpty)
        let json = String(decoding: try JSONEncoder().encode(directory), as: UTF8.self)
        #expect(!json.contains("Secret-123"))
    }

    @Test func signInWithTheRightPassword() throws {
        let (directory, owner) = try directoryWithOwner()
        let result = try directory.signIn(username: "anna", password: "Secret-123", hasher: hasher)
        #expect(result.admin.id == owner.id)
        #expect(!result.mustChangePassword)
    }

    @Test func wrongPasswordAndUnknownUserGiveTheSameError() throws {
        let (directory, _) = try directoryWithOwner()
        #expect(throws: AdminDirectory.DirectoryError.invalidCredentials) {
            try directory.signIn(username: "anna", password: "nope-nope", hasher: hasher)
        }
        #expect(throws: AdminDirectory.DirectoryError.invalidCredentials) {
            try directory.signIn(username: "nobody", password: "Secret-123", hasher: hasher)
        }
    }

    @Test func addedAdminMustChangeTheTemporaryPassword() throws {
        var (directory, owner) = try directoryWithOwner()
        try directory.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                               temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        let first = try directory.signIn(username: "bela", password: "Temp-1234", hasher: hasher)
        #expect(first.mustChangePassword)
        try directory.changePassword(of: first.admin.id, to: "Bela-5678", hasher: hasher)
        let second = try directory.signIn(username: "bela", password: "Bela-5678", hasher: hasher)
        #expect(!second.mustChangePassword)
    }

    @Test func usernamesAreUnique() throws {
        var (directory, owner) = try directoryWithOwner()
        #expect(throws: AdminDirectory.DirectoryError.duplicateUsername("anna")) {
            try directory.addAdmin(name: "Kiss Andrea", username: "anna", role: .userAdmin,
                                   temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        }
    }

    @Test(arguments: [AdminRole.owner, .userAdmin])
    func ownersAndUserAdminsCanManageAdmins(_ role: AdminRole) {
        #expect(role.canManageAdmins)
    }

    @Test func businessManagerCannotManageAdmins() throws {
        var (directory, owner) = try directoryWithOwner()
        let manager = try directory.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                             temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        #expect(throws: AdminDirectory.DirectoryError.notPermitted) {
            try directory.addAdmin(name: "Tóth Cili", username: "cili", role: .userAdmin,
                                   temporaryPassword: "Temp-1234", by: manager.id, hasher: hasher)
        }
    }

    @Test func userAdminCannotCreateOwners() throws {
        var (directory, owner) = try directoryWithOwner()
        let userAdmin = try directory.addAdmin(name: "Tóth Cili", username: "cili", role: .userAdmin,
                                               temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        #expect(throws: AdminDirectory.DirectoryError.notPermitted) {
            try directory.addAdmin(name: "Új Tulaj", username: "tulaj", role: .owner,
                                   temporaryPassword: "Temp-1234", by: userAdmin.id, hasher: hasher)
        }
    }

    @Test func resetPasswordForcesAChange() throws {
        var (directory, owner) = try directoryWithOwner()
        let bela = try directory.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                          temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        try directory.changePassword(of: bela.id, to: "Bela-5678", hasher: hasher)
        try directory.resetPassword(of: bela.id, to: "Temp-9999", by: owner.id, hasher: hasher)
        #expect(try directory.signIn(username: "bela", password: "Temp-9999", hasher: hasher).mustChangePassword)
        #expect(throws: AdminDirectory.DirectoryError.invalidCredentials) {
            try directory.signIn(username: "bela", password: "Bela-5678", hasher: hasher)
        }
    }

    @Test func lastOwnerCannotBeRemoved() throws {
        var (directory, owner) = try directoryWithOwner()
        #expect(throws: AdminDirectory.DirectoryError.lastOwner) {
            try directory.removeAdmin(id: owner.id, by: owner.id)
        }
    }

    @Test func removingAnAdminAlsoRemovesTheCredential() throws {
        var (directory, owner) = try directoryWithOwner()
        let bela = try directory.addAdmin(name: "Nagy Béla", username: "bela", role: .businessManager,
                                          temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        try directory.removeAdmin(id: bela.id, by: owner.id)
        #expect(directory.admins.map(\.username) == ["anna"])
        #expect(directory.credential(for: bela.id) == nil)
    }

    @Test func onlyOwnersSetTheCompanyDomain() throws {
        var (directory, owner) = try directoryWithOwner()
        let cili = try directory.addAdmin(name: "Tóth Cili", username: "cili", role: .userAdmin,
                                          temporaryPassword: "Temp-1234", by: owner.id, hasher: hasher)
        try directory.setCompanyDomain(" ClubNeon.hu ", by: owner.id)
        #expect(directory.email(of: cili) == "cili@clubneon.hu")
        #expect(throws: AdminDirectory.DirectoryError.notPermitted) {
            try directory.setCompanyDomain("other.hu", by: cili.id)
        }
        #expect(throws: AdminDirectory.DirectoryError.invalidDomain) {
            try directory.setCompanyDomain("not a domain", by: owner.id)
        }
    }

    @Test func appleSignInLinksAnInvitedAdminByEmail() throws {
        var (directory, owner) = try directoryWithOwner()
        try directory.setCompanyDomain("clubneon.hu", by: owner.id)
        let dora = try directory.addAdmin(name: "Szabó Dóra", username: "dora", role: .userAdmin,
                                          temporaryPassword: nil, by: owner.id, hasher: hasher)
        #expect(dora.signInMethod == .apple)
        let linked = try directory.signInWithApple(appleID: "apple-dora", email: "dora@clubneon.hu")
        #expect(linked.id == dora.id)
        #expect(try directory.signInWithApple(appleID: "apple-dora", email: nil).id == dora.id)
        #expect(throws: AdminDirectory.DirectoryError.invalidCredentials) {
            try directory.signInWithApple(appleID: "apple-stranger", email: "stranger@clubneon.hu")
        }
    }

    @Test func roleDisplayNames() {
        #expect(AdminRole.owner.displayName == "owner")
        #expect(AdminRole.businessManager.displayName == "business manager")
        #expect(AdminRole.userAdmin.displayName == "user admin")
    }
}
