//
//  TestDoubles.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
@testable import NightlifeWorker

/// Keeps the signed-in Apple user ID in memory instead of the Keychain.
final class InMemoryCredentialStore: CredentialStoring {
    private(set) var userID: String?

    init(userID: String? = nil) {
        self.userID = userID
    }

    func load() -> String? { userID }

    func save(_ userID: String) throws {
        self.userID = userID
    }

    func delete() throws {
        userID = nil
    }
}
