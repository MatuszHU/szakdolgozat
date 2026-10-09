import Foundation
import Testing
@testable import SharedKit

@M11
final class MemoryTipStore: TipStoring {
    var seen: Set<String> = []

    func seenTips() -> Set<String> { seen }
    func save(_ seen: Set<String>) { self.seen = seen }
}

@Suite("Guide tips")
@M11
struct GuideTipCenterTests {
    private let tips = [
        "shop": GuideTip(id: "shop", title: "Buying tickets", message: "Choose a type", symbol: "cart"),
        "map": GuideTip(id: "map", title: "Finding your way", message: "Switch floors", symbol: "map"),
    ]

    @Test func theFirstVisitShowsTheTip() {
        let center = GuideTipCenter(tips: tips, store: MemoryTipStore())
        center.visit("shop")
        #expect(center.current?.id == "shop")
    }

    @Test func aPlaceWithoutATipShowsNothing() {
        let center = GuideTipCenter(tips: tips, store: MemoryTipStore())
        center.visit("settings")
        #expect(center.current == nil)
    }

    @Test func aReadTipIsNotShownAgainAndIsSaved() {
        let store = MemoryTipStore()
        let center = GuideTipCenter(tips: tips, store: store)
        center.visit("shop")
        center.dismiss()
        #expect(center.current == nil)
        #expect(store.seen == ["shop"])
        center.visit("shop")
        #expect(center.current == nil)
        let restarted = GuideTipCenter(tips: tips, store: store)
        restarted.visit("shop")
        #expect(restarted.current == nil)
    }

    @Test func onlyOneTipAtATime() {
        let center = GuideTipCenter(tips: tips, store: MemoryTipStore())
        center.visit("shop")
        center.visit("map")
        #expect(center.current?.id == "shop")
        center.dismiss()
        center.visit("map")
        #expect(center.current?.id == "map")
    }

    @Test func resettingShowsTheTipsAgain() {
        let store = MemoryTipStore()
        let center = GuideTipCenter(tips: tips, store: store)
        center.visit("shop")
        center.dismiss()
        center.reset()
        #expect(store.seen.isEmpty)
        center.visit("shop")
        #expect(center.current?.id == "shop")
    }
}
