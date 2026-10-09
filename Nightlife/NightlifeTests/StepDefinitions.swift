import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

@N8
class NightlifeCucumberTest: CucumberTest { }

extension Cucumber: @retroactive StepImplementation {
    public var bundle: Bundle {
        return Bundle(for: NightlifeCucumberTest.self)
    }

    @N8
    public func setupSteps() {
        setupGuestAuthenticationSteps()
        setupVenueGuideSteps()
        setupTicketPurchaseSteps()
        setupRaffleSteps()
        setupGuestSettingsSteps()
        setupGuestLanguageSteps()
        setupGuestTipsSteps()
    }
}
