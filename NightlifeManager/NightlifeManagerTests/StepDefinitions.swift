//
//  StepDefinitions.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

class NightlifeManagerCucumberTest: CucumberTest { }

extension Cucumber: @retroactive StepImplementation {
    public var bundle: Bundle {
        return Bundle(for: NightlifeManagerCucumberTest.self)
    }

    public func setupSteps() {
        setupVenueDesignerSteps()
        setupStaffMapSteps()
        setupShiftPlanningSteps()
        setupEventManagementSteps()
    }
}
