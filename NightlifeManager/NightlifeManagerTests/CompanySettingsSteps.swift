import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

extension Cucumber {

    @L6
    func setupCompanySettingsSteps(session: @escaping () -> AdminSessionViewModel) {
        func feature(_ name: String) throws -> WorkerFeature {
            try XCTUnwrap(WorkerFeature.allCases.first { $0.displayName == name }, "Unknown feature: \(name)")
        }

        Then("the worker features {string} are on") { match, _ in
            let enabled = WorkerFeature.allCases.filter(session().directory.enabledWorkerFeatures.contains)
            XCTAssertEqual(enabled.map(\.displayName).joined(separator: ", "), try match.first(\.string))
        }

        When("the administrator switches the worker feature {string} off") { match, _ in
            session().setWorkerFeature(try feature(try match.first(\.string)), enabled: false)
            XCTAssertNil(session().errorMessage)
        }

        When("the administrator switches the worker feature {string} on") { match, _ in
            session().setWorkerFeature(try feature(try match.first(\.string)), enabled: true)
            XCTAssertNil(session().errorMessage)
        }

        When("the administrator changes the password from {string} to {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            session().changeOwnPassword(current: texts[0], new: texts[1])
        }
    }
}
