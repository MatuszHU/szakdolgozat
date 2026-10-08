import Foundation
@testable import AdminCore

struct TestPasswordHasher: PasswordHashing {
    func makeSalt() -> Data {
        Data(UUID().uuidString.utf8)
    }

    func hash(_ password: String, salt: Data) -> Data {
        Data((String(decoding: salt, as: UTF8.self) + "|" + String(password.reversed())).utf8)
    }
}
