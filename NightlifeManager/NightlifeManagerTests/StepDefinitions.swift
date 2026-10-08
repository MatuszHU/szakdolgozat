import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

@N8
class NightlifeManagerCucumberTest: CucumberTest { }

extension Cucumber: @retroactive StepImplementation {
    public var bundle: Bundle {
        return Bundle(for: NightlifeManagerCucumberTest.self)
    }

    @N8
    public func setupSteps() {
        setupVenueDesignerSteps()
        setupStaffMapSteps()
        setupShiftPlanningSteps()
        setupEventManagementSteps()
        setupAdminAccessSteps()
    }
}
