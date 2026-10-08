import Foundation
import SharedKit
@testable import NightlifeWorker

@K4 @K14
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
