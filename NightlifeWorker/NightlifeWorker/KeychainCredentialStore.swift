import Foundation
import Security
import SharedKit

@K4 @K14
protocol CredentialStoring {
    func load() -> String?
    func save(_ userID: String) throws
    func delete() throws
}

@K4 @K14 @N3
struct KeychainCredentialStore: CredentialStoring {
    struct KeychainError: Error {
        let status: OSStatus
    }

    private let service: String
    private let account = "apple-user-id"

    init(service: String = "hu.matusz.nightlife.worker.signin") {
        self.service = service
    }

    private var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    func load() -> String? {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(request as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func save(_ userID: String) throws {
        try delete()
        var item = query
        item[kSecValueData as String] = Data(userID.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }

    func delete() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError(status: status) }
    }
}
