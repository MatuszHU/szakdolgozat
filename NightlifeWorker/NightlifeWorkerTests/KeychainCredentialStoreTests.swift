import Foundation
import Testing
import SharedKit
@testable import NightlifeWorker

@Suite("KeychainCredentialStore", .serialized)
@K4 @K14 @N3
struct KeychainCredentialStoreTests {

    private let store = KeychainCredentialStore(service: "hu.matusz.nightlife.tests.\(UUID().uuidString)")

    @Test func savesLoadsAndDeletesTheUser() throws {
        #expect(store.load() == nil)
        try store.save("apple-id")
        #expect(store.load() == "apple-id")
        try store.save("other-id")
        #expect(store.load() == "other-id")
        try store.delete()
        #expect(store.load() == nil)
    }

    @Test func deletingWithoutStoredUserIsFine() throws {
        try store.delete()
        #expect(store.load() == nil)
    }
}
