import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

@N8
struct UnknownScenarioName: Error {
    let name: String
}

@K16
enum World {
    static var zones: [Zone] = []
    static var enabledFeatures = Set(WorkerFeature.allCases)

    static func zone(named name: String) -> Zone {
        guard let zone = zones.first(where: { $0.name == name }) else {
            XCTFail("Unknown zone in scenario: \(name)")
            return Zone(name: name)
        }
        return zone
    }
}

extension Cucumber {

    @K16
    func setupCommonSteps() {
        var home: HomeMenuViewModel!

        func homeItem(_ name: String) throws -> HomeItem {
            switch name {
            case "Schedule": return .schedule
            case "Code reader": return .codeReader
            case "Map": return .map
            case "Supply request": return .supplyRequest
            case "Summary": return .summary
            case "Notifications": return .notifications
            default: throw UnknownScenarioName(name: name)
            }
        }

        func feature(_ name: String) throws -> WorkerFeature {
            switch name {
            case "supply requests": return .supplyRequests
            case "statistics": return .statistics
            case "profile picture": return .profilePicture
            case "guide": return .guide
            default: throw UnknownScenarioName(name: name)
            }
        }

        BeforeScenario { _ in
            World.zones = []
            World.enabledFeatures = Set(WorkerFeature.allCases)
            home = nil
        }

        Given("the venue has the zones {string} and {string}") { match, _ in
            World.zones = try match.allParameters(\.string).map { Zone(name: $0) }
        }

        Given("the administrator turned off {string}") { match, _ in
            World.enabledFeatures.remove(try feature(try match.first(\.string)))
        }

        When("I open the home screen") { _, _ in
            home = HomeMenuViewModel(enabledFeatures: World.enabledFeatures)
        }

        Then("the home screen does not offer {string}") { match, _ in
            XCTAssertFalse(home.items.contains(try homeItem(try match.first(\.string))))
        }

        Then("the home screen offers {string}") { match, _ in
            XCTAssertTrue(home.items.contains(try homeItem(try match.first(\.string))))
        }
    }
}
