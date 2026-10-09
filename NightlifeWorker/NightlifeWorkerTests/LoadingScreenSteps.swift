import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    @K3
    func setupLoadingScreenSteps() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        var clock = start
        var loads: [Int: UUID] = [:]
        var viewModel: LoadingViewModel!

        func at(_ milliseconds: Int) -> Date {
            start.addingTimeInterval(Double(milliseconds) / 1000)
        }

        BeforeScenario { _ in
            clock = start
            loads = [:]
            MainActor.assumeIsolated {
                viewModel = LoadingViewModel(now: { clock })
            }
        }

        Given("a load starts at {int} ms") { match, _ in
            let milliseconds = try match.first(\.int)
            clock = at(milliseconds)
            loads[milliseconds] = MainActor.assumeIsolated { viewModel.begin() }
        }

        When("it is {int} ms") { match, _ in
            clock = at(try match.first(\.int))
            MainActor.assumeIsolated { viewModel.refresh() }
        }

        When("the load started at {int} ms ends at {int} ms") { match, _ in
            let times = try match.allParameters(\.int)
            let id = try XCTUnwrap(loads[times[0]])
            clock = at(times[1])
            MainActor.assumeIsolated { viewModel.end(id) }
        }

        Then("the loading screen is shown") { _, _ in
            XCTAssertTrue(MainActor.assumeIsolated { viewModel.showsLoadingScreen })
        }

        Then("the loading screen is not shown") { _, _ in
            XCTAssertFalse(MainActor.assumeIsolated { viewModel.showsLoadingScreen })
        }

        Then("the loading screen has not been shown at all") { _, _ in
            XCTAssertFalse(MainActor.assumeIsolated { viewModel.showsLoadingScreen })
            XCTAssertFalse(MainActor.assumeIsolated { viewModel.hasShownLoadingScreen })
        }
    }
}
