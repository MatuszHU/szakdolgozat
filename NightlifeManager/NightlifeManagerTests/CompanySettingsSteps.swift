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
            let expected = try match.first(\.string)
            MainActor.assumeIsolated {
                let enabled = WorkerFeature.allCases.filter(session().snapshot.enabledWorkerFeatures.contains)
                XCTAssertEqual(enabled.map(\.displayName).joined(separator: ", "), expected)
            }
        }

        When("the administrator switches the worker feature {string} off") { match, _ in
            let switched = try feature(try match.first(\.string))
            MainActor.assumeIsolated {
                waitFor { await session().setWorkerFeature(switched, enabled: false) }
                XCTAssertNil(session().errorMessage)
            }
        }

        When("the administrator switches the worker feature {string} on") { match, _ in
            let switched = try feature(try match.first(\.string))
            MainActor.assumeIsolated {
                waitFor { await session().setWorkerFeature(switched, enabled: true) }
                XCTAssertNil(session().errorMessage)
            }
        }

        When("the administrator changes the password from {string} to {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            MainActor.assumeIsolated {
                waitFor { await session().changeOwnPassword(current: texts[0], new: texts[1]) }
            }
        }
    }
}
