//
//  ZoneCheckInSteps.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    func setupZoneCheckInSteps() {
        var viewModel: ZoneCheckInViewModel!

        Given("the worker is on shift") { _, _ in
            viewModel = ZoneCheckInViewModel(workerID: UUID(), zones: World.zones, isOnShift: true)
        }

        Given("the worker is not on shift") { _, _ in
            viewModel = ZoneCheckInViewModel(workerID: UUID(), zones: World.zones, isOnShift: false)
        }

        Given("the worker is checked in to the {string} zone") { match, _ in
            let target = World.zone(named: try match.first(\.string))
            viewModel.scan(target.qrPayload)
            XCTAssertEqual(viewModel.currentZone?.id, target.id)
        }

        When("the worker scans the QR code of the {string} zone") { match, _ in
            viewModel.scan(World.zone(named: try match.first(\.string)).qrPayload)
        }

        When("the worker scans a QR code that does not belong to a zone") { _, _ in
            viewModel.scan("https://example.com/not-a-zone")
        }

        When("the worker's shift ends") { _, _ in
            viewModel.endShift()
        }

        Then("the worker's position is the {string} zone") { match, _ in
            XCTAssertEqual(viewModel.currentZone?.id, World.zone(named: try match.first(\.string)).id)
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
