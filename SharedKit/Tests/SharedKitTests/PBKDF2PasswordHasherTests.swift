import Foundation
import Testing
@testable import SharedKit

@Suite("PBKDF2PasswordHasher")
@L1 @N3
struct PBKDF2PasswordHasherTests {

    private let hasher = PBKDF2PasswordHasher(iterations: 1_000)

    @Test func sameInputGivesTheSameHash() {
        let salt = hasher.makeSalt()
        #expect(hasher.hash("Secret-123", salt: salt) == hasher.hash("Secret-123", salt: salt))
        #expect(hasher.hash("Secret-123", salt: salt).count == 32)
    }

    @Test func saltsAreRandomAndChangeTheHash() {
        let first = hasher.makeSalt()
        let second = hasher.makeSalt()
        #expect(first != second)
        #expect(hasher.hash("Secret-123", salt: first) != hasher.hash("Secret-123", salt: second))
    }

    @Test func verifyAcceptsOnlyTheRightPassword() {
        let salt = hasher.makeSalt()
        let stored = hasher.hash("Secret-123", salt: salt)
        #expect(hasher.verify("Secret-123", hash: stored, salt: salt))
        #expect(!hasher.verify("Secret-124", hash: stored, salt: salt))
    }

    @Test func directoryStoresOnlySaltedHashes() throws {
        var directory = AdminDirectory()
        let owner = try directory.createOwner(name: "Kiss Anna", username: "anna", password: "Secret-123", hasher: hasher)
        let credential = try #require(directory.credential(for: owner.id))
        #expect(credential.hash != Data("Secret-123".utf8))
        #expect(credential.salt.count == 16)
        #expect(!String(decoding: try JSONEncoder().encode(directory), as: UTF8.self).contains("Secret-123"))
    }
}
