import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

@N8
struct UnknownGuestScenarioName: Error {
    let name: String
}

@M11
final class InMemoryGuestTipStore: TipStoring {
    private(set) var seen: Set<String> = []

    func seenTips() -> Set<String> { seen }
    func save(_ seen: Set<String>) { self.seen = seen }
}

extension Cucumber {

    @M11
    func setupGuestTipsSteps() {
        var store = InMemoryGuestTipStore()
        var center: GuideTipCenter!

        func place(_ name: String) throws -> GuestPlace {
            switch name {
            case "home screen": return .home
            case "ticket shop": return .ticketShop
            case "my tickets": return .myTickets
            case "map": return .map
            case "raffles": return .raffle
            default: throw UnknownGuestScenarioName(name: name)
            }
        }

        BeforeScenario { _ in
            store = InMemoryGuestTipStore()
            center = GuideTipCenter.guest(store: store)
        }

        Given("the guest opened the {string} and read the tip") { match, _ in
            center.visit(try place(try match.first(\.string)))
            XCTAssertNotNil(center.current)
            center.dismiss()
        }

        When("the guest opens the {string}") { match, _ in
            center.visit(try place(try match.first(\.string)))
        }

        When("the guest app is started again") { _, _ in
            center = GuideTipCenter.guest(store: store)
        }

        When("the guest asks for the tips again in the settings") { _, _ in
            let auth = AuthViewModel(store: InMemoryCredentialStore())
            GuestSettingsViewModel(auth: auth, guestName: nil, tips: center).showTipsAgain()
        }

        Then("a tip with a picture explains {string}") { match, _ in
            let tip = try XCTUnwrap(center.current)
            XCTAssertEqual(english(tip.title), try match.first(\.string))
            XCTAssertFalse((english(tip.message) ?? "").isEmpty)
            XCTAssertFalse(tip.symbol.isEmpty)
        }

        Then("no tip is shown") { _, _ in
            XCTAssertNil(center.current)
        }
    }
}
