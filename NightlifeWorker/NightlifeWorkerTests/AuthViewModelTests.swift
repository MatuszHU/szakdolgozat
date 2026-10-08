//
//  AuthViewModelTests.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
import Testing
@testable import NightlifeWorker

@Suite("AuthViewModel")
struct AuthViewModelTests {

    @Test func withoutStoredSignInTheWelcomeScreenIsShown() {
        let viewModel = AuthViewModel(store: InMemoryCredentialStore())
        viewModel.checkAuthState()
        #expect(!viewModel.isAuthenticated)
        #expect(viewModel.showWelcome)
    }

    @Test func storedSignInOpensTheHomeScreen() {
        let viewModel = AuthViewModel(store: InMemoryCredentialStore(userID: "apple-id"))
        viewModel.checkAuthState()
        #expect(viewModel.isAuthenticated)
        #expect(!viewModel.showWelcome)
    }

    @Test func signingInStoresTheUser() {
        let store = InMemoryCredentialStore()
        let viewModel = AuthViewModel(store: store)
        viewModel.signInWithApple(userID: "apple-id")
        #expect(store.userID == "apple-id")
        #expect(viewModel.isAuthenticated)
    }

    @Test func signingOutForgetsTheUser() {
        let store = InMemoryCredentialStore(userID: "apple-id")
        let viewModel = AuthViewModel(store: store)
        viewModel.checkAuthState()
        viewModel.signOut()
        #expect(store.userID == nil)
        #expect(!viewModel.isAuthenticated)
        #expect(viewModel.showWelcome)
    }

    @Test func cancellingKeepsTheWelcomeScreenAndStoresNothing() {
        let store = InMemoryCredentialStore()
        let viewModel = AuthViewModel(store: store)
        viewModel.cancelSignIn()
        #expect(store.userID == nil)
        #expect(viewModel.showWelcome)
    }
}

@Suite("KeychainCredentialStore", .serialized)
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
