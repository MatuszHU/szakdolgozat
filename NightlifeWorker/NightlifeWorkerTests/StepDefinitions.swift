//
//  StepDefinitions.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 16..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

class NightlifeWorkerCucumberTest: CucumberTest { }

extension Cucumber: @retroactive StepImplementation {
    public var bundle: Bundle {
        return Bundle(for: NightlifeWorkerCucumberTest.self)
    }

    public func setupSteps() {
        var viewModel: AuthViewModel!

        Given("the app is launched for the first time") { _, _ in
            viewModel = AuthViewModel()
            XCTAssertFalse(viewModel.isAuthenticated)
            XCTAssertTrue(viewModel.showWelcome)
        }

        When("the user taps \"Sign in with Apple\"") { _, _ in
            viewModel.signInWithApple()
        }

        Then("the user is taken to the home screen") { _, _ in
            XCTAssertTrue(viewModel.isAuthenticated)
            XCTAssertFalse(viewModel.showWelcome)
        }

        Given("the user is already authenticated") { _, _ in
            viewModel = AuthViewModel(authenticated: true)
        }

        When("the app launches") { _, _ in
            viewModel.checkAuthState()
        }

        Then("the user is taken directly to the home screen") { _, _ in
            XCTAssertTrue(viewModel.isAuthenticated)
            XCTAssertFalse(viewModel.showWelcome)
        }

        Given("the app is launched") { _, _ in
            viewModel = AuthViewModel()
        }

        When("the user cancels the Sign in with Apple flow") { _, _ in
            viewModel.cancelSignIn()
        }

        Then("the user remains on the welcome screen") { _, _ in
            XCTAssertFalse(viewModel.isAuthenticated)
            XCTAssertTrue(viewModel.showWelcome)
        }


        var shiftViewModel: ShiftConflictViewModel!

        Given("the worker has a shift from {int}:{int} to {int}:{int}") { match, _ in
            let time = try match.allParameters(\.int)
            shiftViewModel = ShiftConflictViewModel(workerID: UUID())
            shiftViewModel.addShift(startHour: time[0], startMinute: time[1], endHour: time[2], endMinute: time[3])
        }

        When("a shift from {int}:{int} to {int}:{int} is assigned") { match, _ in
            let time = try match.allParameters(\.int)
            shiftViewModel.addShift(startHour: time[0], startMinute: time[1], endHour: time[2], endMinute: time[3])
        }

        Then("a shift conflict error is shown") { _, _ in
            XCTAssertTrue(shiftViewModel.conflictDetected)
        }

        Then("the shift is assigned successfully") { _, _ in
            XCTAssertFalse(shiftViewModel.conflictDetected)
            XCTAssertNotNil(shiftViewModel.lastAddedShift)
        }

        setupZoneCheckInSteps()
    }
}
