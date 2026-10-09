import Foundation
import Testing
@testable import SharedKit

@Suite("Loading tracker")
@K3
struct LoadingTrackerTests {
    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    private func at(_ milliseconds: Double) -> Date {
        start.addingTimeInterval(milliseconds / 1000)
    }

    @Test func aLongLoadShowsTheScreenAfterTheDelay() {
        var tracker = LoadingTracker()
        let load = tracker.begin(at: at(0))
        #expect(tracker.isLoading)
        #expect(!tracker.showsLoadingScreen(at: at(299)))
        #expect(tracker.showsLoadingScreen(at: at(300)))
        tracker.end(load)
        #expect(!tracker.isLoading)
        #expect(!tracker.showsLoadingScreen(at: at(2000)))
    }

    @Test func theScreenStaysUntilEveryLoadHasEnded() {
        var tracker = LoadingTracker()
        let first = tracker.begin(at: at(0))
        let second = tracker.begin(at: at(200))
        tracker.end(first)
        #expect(!tracker.showsLoadingScreen(at: at(400)))
        #expect(tracker.showsLoadingScreen(at: at(500)))
        tracker.end(second)
        #expect(!tracker.showsLoadingScreen(at: at(1500)))
    }

    @Test func endingAnUnknownLoadChangesNothing() {
        var tracker = LoadingTracker()
        tracker.begin(at: at(0))
        tracker.end(UUID())
        #expect(tracker.showsLoadingScreen(at: at(1000)))
    }

    @Test func nothingIsShownWithoutLoads() {
        #expect(!LoadingTracker().showsLoadingScreen(at: at(1000)))
    }
}
