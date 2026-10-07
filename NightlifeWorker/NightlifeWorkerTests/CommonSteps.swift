//
//  CommonSteps.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit

/// Shared scenario state ("World") for steps used by more than one feature.
/// Every step text may be defined only once, so shared steps live here.
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

    func setupCommonSteps() {
        BeforeScenario { _ in
            World.zones = []
        }

        Given("the venue has the zones {string} and {string}") { match, _ in
            World.zones = try match.allParameters(\.string).map { Zone(name: $0) }
        }
    }
}
