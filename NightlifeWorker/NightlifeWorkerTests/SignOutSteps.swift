//
//  SignOutSteps.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
@testable import NightlifeWorker

extension Cucumber {

    func setupSignOutSteps() {
        var store = InMemoryCredentialStore()
        var viewModel: AuthViewModel!

        BeforeScenario { _ in
            store = InMemoryCredentialStore()
            viewModel = nil
        }

        Given("the worker signed in with Apple") { _, _ in
            viewModel = AuthViewModel(store: store)
            viewModel.signInWithApple(userID: "worker-apple-id")
            XCTAssertTrue(viewModel.isAuthenticated)
        }

        When("the worker signs out") { _, _ in
            viewModel.signOut()
        }

        When("the app is restarted") { _, _ in
            viewModel = AuthViewModel(store: store)
            viewModel.checkAuthState()
        }

        Then("the welcome screen is shown") { _, _ in
            XCTAssertFalse(viewModel.isAuthenticated)
            XCTAssertTrue(viewModel.showWelcome)
        }

        Then("the home screen is shown") { _, _ in
            XCTAssertTrue(viewModel.isAuthenticated)
            XCTAssertFalse(viewModel.showWelcome)
        }
    }
}
