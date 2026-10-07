//
//  ThisBundle.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 16..
//


import XCTest
import CucumberSwift
import SharedKit

class ShiftConflictViewModel {
    private(set) var schedule: Schedule
    private(set) var conflictDetected: Bool = false
    private(set) var lastAddedShift: Shift?

    init(workerID: UUID) {
        schedule = Schedule(workerID: workerID, payPeriod: .weekly)
    }

    func addShift(startHour: Int, endHour: Int) {
        var shift = makeShift(startHour: startHour, endHour: endHour)
        if schedule.hasConflict(for: shift, workerID: schedule.workerID) {
            conflictDetected = true
        } else {
            conflictDetected = false
            _ = shift.assign(workerID: schedule.workerID)
            schedule.shifts.append(shift)
            lastAddedShift = shift
        }
    }

    private func makeShift(startHour: Int, endHour: Int) -> Shift {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .hour, value: startHour, to: today)!
        var end = calendar.date(byAdding: .hour, value: endHour, to: today)!
        if endHour <= startHour {
            end = calendar.date(byAdding: .day, value: 1, to: end)!
        }
        return Shift(startTime: start, endTime: end, location: "")
    }
}

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

        Given("a workernek van egy műszakja (\\d+):(\\d+)-tól (\\d+):(\\d+)-ig") { match, _ in
            shiftViewModel = ShiftConflictViewModel(workerID: UUID())
            shiftViewModel.addShift(startHour: Int(match[1])!, endHour: Int(match[3])!)
        }

        When("hozzárendelik (\\d+):(\\d+)-tól (\\d+):(\\d+)-ig") { match, _ in
            shiftViewModel.addShift(startHour: Int(match[1])!, endHour: Int(match[3])!)
        }

        Then("ütközési hiba jelenik meg") { _, _ in
            XCTAssertTrue(shiftViewModel.conflictDetected)
        }

        Then("a műszak sikeresen hozzárendelve") { _, _ in
            XCTAssertFalse(shiftViewModel.conflictDetected)
            XCTAssertNotNil(shiftViewModel.lastAddedShift)
        }
    }
}
