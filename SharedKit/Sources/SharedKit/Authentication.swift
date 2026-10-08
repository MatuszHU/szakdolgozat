import Foundation
import Combine
import Security

@K4 @K14 @M3 @M6
public protocol CredentialStoring {
    func load() -> String?
    func save(_ userID: String) throws
    func delete() throws
}

@K4 @K14 @M3 @M6 @N3
public struct KeychainCredentialStore: CredentialStoring {
    public struct KeychainError: Error {
        public let status: OSStatus
    }

    private let service: String
    private let account = "apple-user-id"

    public init(service: String) {
        self.service = service
    }

    private var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: service,
         kSecAttrAccount as String: account]
    }

    public func load() -> String? {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(request as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func save(_ userID: String) throws {
        try delete()
        var item = query
        item[kSecValueData as String] = Data(userID.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }

    public func delete() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError(status: status) }
    }
}

@K4 @K14 @M3 @M6
public final class InMemoryCredentialStore: CredentialStoring {
    private var userID: String?

    public init(userID: String? = nil) {
        self.userID = userID
    }

    public func load() -> String? { userID }

    public func save(_ userID: String) throws {
        self.userID = userID
    }

    public func delete() throws {
        userID = nil
    }
}

@K1 @K2 @K4 @K14 @M1 @M2 @M3 @M6
public final class AuthViewModel: ObservableObject {
    @Published public private(set) var isAuthenticated = false
    @Published public private(set) var showWelcome = true
    @Published public private(set) var userID: String?
    private let store: CredentialStoring

    public init(store: CredentialStoring) {
        self.store = store
    }

    public func checkAuthState() {
        userID = store.load()
        isAuthenticated = userID != nil
        showWelcome = !isAuthenticated
    }

    public func signInWithApple(userID: String) {
        try? store.save(userID)
        self.userID = userID
        isAuthenticated = true
        showWelcome = false
    }

    public func cancelSignIn() {
        isAuthenticated = false
        showWelcome = true
    }

    public func signOut() {
        try? store.delete()
        userID = nil
        isAuthenticated = false
        showWelcome = true
    }
}
