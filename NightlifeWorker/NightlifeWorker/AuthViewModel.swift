//
//  AuthViewModel.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 22..
//

import Foundation
import Combine

/// Sign in with Apple, remembered sign-in and sign out (K1, K2, K4, K14).
class AuthViewModel: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var showWelcome = true
    private let store: CredentialStoring

    init(store: CredentialStoring) {
        self.store = store
    }

    /// Restores a remembered sign-in at launch.
    func checkAuthState() {
        isAuthenticated = store.load() != nil
        showWelcome = !isAuthenticated
    }

    func signInWithApple(userID: String) {
        try? store.save(userID)
        isAuthenticated = true
        showWelcome = false
    }

    func cancelSignIn() {
        isAuthenticated = false
        showWelcome = true
    }

    func signOut() {
        try? store.delete()
        isAuthenticated = false
        showWelcome = true
    }
}
