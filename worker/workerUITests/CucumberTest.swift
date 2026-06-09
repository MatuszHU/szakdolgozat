import XCTest
import Cucumberish

class CucumberTest: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        // Regisztráld a step-eket
        registerWelcomeSteps()
        
        // Futtasd a Features mappában lévő feature-eket
        let bundle = Bundle(for: CucumberTest.self)
        Cucumberish.executeFeatures(
            inDirectory: "Features",
            from: bundle,
            includeTags: nil,
            excludeTags: nil
        )
    }
    
    private class func registerWelcomeSteps() {
        Given("^the app is launched$") { _, _ in
            XCUIApplication().launch()
        }

        Then("^I should see the title \"([^\"]*)\"$") { args, _ in
            guard let title = args?.first else { return }
            XCTAssertTrue(XCUIApplication().staticTexts[title].exists)
        }

        Then("^I should see the message \"([^\"]*)\"$") { args, _ in
            guard let message = args?.first else { return }
            XCTAssertTrue(XCUIApplication().staticTexts[message].exists)
        }

        Then("^I should see a \"([^\"]*)\" button$") { args, _ in
            guard let buttonTitle = args?.first else { return }
            XCTAssertTrue(XCUIApplication().buttons[buttonTitle].exists)
        }

        When("^I tap the \"([^\"]*)\" button$") { args, _ in
            guard let buttonTitle = args?.first else { return }
            XCUIApplication().buttons[buttonTitle].tap()
        }
    }
}
