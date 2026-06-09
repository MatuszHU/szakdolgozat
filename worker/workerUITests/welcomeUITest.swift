import XCTest
import Cucumberish

class WelcomeViewSteps: NSObject {

    @objc static func registerSteps() {

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
