import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit

@K16
enum World {
    static var zones: [Zone] = []

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
        BeforeScenario { _ in
            World.zones = []
        }

        Given("the venue has the zones {string} and {string}") { match, _ in
            World.zones = try match.allParameters(\.string).map { Zone(name: $0) }
        }
    }
}
