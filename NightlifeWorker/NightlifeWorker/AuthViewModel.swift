//
//  AuthViewModel.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 22..
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var showWelcome: Bool

    init(authenticated: Bool = false) {
        self.isAuthenticated = authenticated
        self.showWelcome = !authenticated
    }

    func signInWithApple() {
        isAuthenticated = true
        showWelcome = false
    }

    func cancelSignIn() {
        isAuthenticated = false
        showWelcome = true
    }

    func checkAuthState() {
        showWelcome = !isAuthenticated
    }
}
