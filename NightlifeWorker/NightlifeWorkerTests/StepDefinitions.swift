import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

@N8
class NightlifeWorkerCucumberTest: CucumberTest { }

extension Cucumber: @retroactive StepImplementation {
    public var bundle: Bundle {
        return Bundle(for: NightlifeWorkerCucumberTest.self)
    }

    @K1 @K2 @K4
    public func setupSteps() {
        var viewModel: AuthViewModel!

        Given("the app is launched for the first time") { _, _ in
            viewModel = AuthViewModel(store: InMemoryCredentialStore())
            viewModel.checkAuthState()
            XCTAssertFalse(viewModel.isAuthenticated)
            XCTAssertTrue(viewModel.showWelcome)
        }

        When("the user taps \"Sign in with Apple\"") { _, _ in
            viewModel.signInWithApple(userID: "worker-apple-id")
        }

        Then("the user is taken to the home screen") { _, _ in
            XCTAssertTrue(viewModel.isAuthenticated)
            XCTAssertFalse(viewModel.showWelcome)
        }

        Given("the user is already authenticated") { _, _ in
            viewModel = AuthViewModel(store: InMemoryCredentialStore(userID: "worker-apple-id"))
        }

        When("the app launches") { _, _ in
            viewModel.checkAuthState()
        }

        Then("the user is taken directly to the home screen") { _, _ in
            XCTAssertTrue(viewModel.isAuthenticated)
            XCTAssertFalse(viewModel.showWelcome)
        }

        Given("the app is launched") { _, _ in
            viewModel = AuthViewModel(store: InMemoryCredentialStore())
            viewModel.checkAuthState()
        }

        When("the user cancels the Sign in with Apple flow") { _, _ in
            viewModel.cancelSignIn()
        }

        Then("the user remains on the welcome screen") { _, _ in
            XCTAssertFalse(viewModel.isAuthenticated)
            XCTAssertTrue(viewModel.showWelcome)
        }

        setupCommonSteps()
        setupZoneCheckInSteps()
        setupPanicModeSteps()
        setupCodeReaderSteps()
        setupVenueMapSteps()
        setupSignOutSteps()
        setupScheduleSteps()
    }
}
