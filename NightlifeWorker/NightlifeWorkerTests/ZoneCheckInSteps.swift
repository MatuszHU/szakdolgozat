//
//  ZoneCheckInSteps.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import XCTest
import CucumberSwift
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    func setupZoneCheckInSteps() {
        var zones: [Zone] = []
        var viewModel: ZoneCheckInViewModel!

        func zone(named name: String) -> Zone {
            guard let zone = zones.first(where: { $0.name == name }) else {
                XCTFail("Unknown zone in scenario: \(name)")
                return Zone(name: name)
            }
            return zone
        }

        Given("the venue has the zones \"([^\"]+)\" and \"([^\"]+)\"") { match, _ in
            zones = [Zone(name: String(match[1])), Zone(name: String(match[2]))]
        }

        Given("the worker is on shift") { _, _ in
            viewModel = ZoneCheckInViewModel(workerID: UUID(), zones: zones, isOnShift: true)
        }

        Given("the worker is not on shift") { _, _ in
            viewModel = ZoneCheckInViewModel(workerID: UUID(), zones: zones, isOnShift: false)
        }

        Given("the worker is checked in to the \"([^\"]+)\" zone") { match, _ in
            let target = zone(named: String(match[1]))
            viewModel.scan(target.qrPayload)
            XCTAssertEqual(viewModel.currentZone?.id, target.id)
        }

        When("the worker scans the QR code of the \"([^\"]+)\" zone") { match, _ in
            viewModel.scan(zone(named: String(match[1])).qrPayload)
        }

        When("the worker scans a QR code that does not belong to a zone") { _, _ in
            viewModel.scan("https://example.com/not-a-zone")
        }

        When("the worker's shift ends") { _, _ in
            viewModel.endShift()
        }

        Then("the worker's position is the \"([^\"]+)\" zone") { match, _ in
            XCTAssertEqual(viewModel.currentZone?.id, zone(named: String(match[1])).id)
        }

        Then("an invalid code error is shown") { _, _ in
            XCTAssertEqual(viewModel.lastError, .invalidCode)
        }

        Then("a not on shift error is shown") { _, _ in
            XCTAssertEqual(viewModel.lastError, .notOnShift)
        }

        Then("the worker has no position") { _, _ in
            XCTAssertNil(viewModel.currentZone)
        }
    }
}
