import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

extension Cucumber {

    @M1 @M2 @M3 @M6
    func setupGuestAuthenticationSteps() {
        var store = InMemoryCredentialStore()
        var viewModel: AuthViewModel!

        func launch() {
            viewModel = AuthViewModel(store: store)
            viewModel.checkAuthState()
        }

        BeforeScenario { _ in
            store = InMemoryCredentialStore()
            viewModel = nil
        }

        Given("the guest app is launched for the first time") { _, _ in
            launch()
        }

        Given("the guest signed in earlier") { _, _ in
            store = InMemoryCredentialStore(userID: "guest-apple-id")
            launch()
        }

        When("the guest signs in with Apple") { _, _ in
            viewModel.signInWithApple(userID: "guest-apple-id")
        }

        When("the guest cancels the sign-in") { _, _ in
            viewModel.cancelSignIn()
        }

        When("the guest signs out") { _, _ in
            viewModel.signOut()
        }

        When("the guest app is restarted") { _, _ in
            launch()
        }

        Then("the guest sees the welcome screen") { _, _ in
            XCTAssertFalse(viewModel.isAuthenticated)
            XCTAssertTrue(viewModel.showWelcome)
        }

        Then("the guest sees the home screen") { _, _ in
            XCTAssertTrue(viewModel.isAuthenticated)
            XCTAssertFalse(viewModel.showWelcome)
        }
    }
}
