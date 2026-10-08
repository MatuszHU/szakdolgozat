import Foundation
import CommonCrypto
import Security
import AdminCore

@L1 @N3
public struct PBKDF2PasswordHasher: PasswordHashing {
    public let iterations: UInt32

    public init(iterations: UInt32 = 600_000) {
        self.iterations = iterations
    }

    public func makeSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
    }

    public func hash(_ password: String, salt: Data) -> Data {
        var derived = [UInt8](repeating: 0, count: 32)
        let saltBytes = [UInt8](salt)
        _ = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), password, password.utf8.count,
                                 saltBytes, saltBytes.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                                 iterations, &derived, derived.count)
        return Data(derived)
    }
}
