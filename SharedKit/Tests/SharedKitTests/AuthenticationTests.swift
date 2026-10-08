import Foundation
import Testing
@testable import SharedKit

@Suite("AuthViewModel")
@K1 @K2 @K4 @K14 @M1 @M2 @M3 @M6
struct AuthenticationTests {

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
        #expect(store.load() == "apple-id")
        #expect(viewModel.isAuthenticated)
    }

    @Test func signingOutForgetsTheUser() {
        let store = InMemoryCredentialStore(userID: "apple-id")
        let viewModel = AuthViewModel(store: store)
        viewModel.checkAuthState()
        viewModel.signOut()
        #expect(store.load() == nil)
        #expect(!viewModel.isAuthenticated)
        #expect(viewModel.showWelcome)
    }

    @Test func cancellingKeepsTheWelcomeScreenAndStoresNothing() {
        let store = InMemoryCredentialStore()
        let viewModel = AuthViewModel(store: store)
        viewModel.cancelSignIn()
        #expect(store.load() == nil)
        #expect(viewModel.showWelcome)
    }

    @Test func separateStoresDoNotShareTheSignIn() {
        let worker = InMemoryCredentialStore(userID: "worker-id")
        let guest = InMemoryCredentialStore()
        let guestApp = AuthViewModel(store: guest)
        guestApp.checkAuthState()
        #expect(!guestApp.isAuthenticated)
        #expect(worker.load() == "worker-id")
    }
}
