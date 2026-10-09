import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

@M10
final class InMemoryGuestLanguageStore: LanguageStoring {
    private(set) var saved: AppLanguage?

    func load() -> AppLanguage? { saved }
    func save(_ language: AppLanguage) { saved = language }
}

extension Cucumber {

    @M10
    func setupGuestLanguageSteps() {
        var store = InMemoryGuestLanguageStore()
        var settings: LanguageSettings!

        func language(_ code: String) throws -> AppLanguage {
            try XCTUnwrap(AppLanguage(rawValue: code), "Unknown language in scenario: \(code)")
        }

        func open() {
            settings = LanguageSettings(store: store, supported: AppLanguage.guest)
        }

        func choose(_ match: Match) throws {
            if settings == nil { open() }
            settings.choose(try language(try match.first(\.string)))
        }

        func text(_ key: String) -> String {
            settings.text(LocalizedStringResource(String.LocalizationValue(key)))
        }

        BeforeScenario { _ in
            store = InMemoryGuestLanguageStore()
            settings = nil
        }

        Given("the guest chose {string} as the language") { match, _ in
            try choose(match)
        }

        When("the guest chooses {string} as the language") { match, _ in
            try choose(match)
        }

        When("the guest opens the language settings") { _, _ in
            open()
        }

        When("the guest's language settings are opened again") { _, _ in
            open()
        }

        Then("the guest's chosen language is {string}") { match, _ in
            XCTAssertEqual(settings.language, try language(try match.first(\.string)))
        }

        Then("the home screen item {string} reads {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            XCTAssertEqual(text(texts[0]), texts[1])
        }

        Then("the raffle confirmation reads {string}") { match, _ in
            XCTAssertEqual(text("You are registered. Good luck!"), try match.first(\.string))
        }

        Then("every text of the guest app has a version in all eight languages") { _, _ in
            var keySets: [String: Set<String>] = [:]
            for language in AppLanguage.guest.compactMap(\.locale).map(\.identifier) {
                let url = try XCTUnwrap(Bundle.main.url(forResource: "Localizable", withExtension: "strings",
                                                        subdirectory: nil, localization: language),
                                        "No \(language) strings")
                let strings = try XCTUnwrap(NSDictionary(contentsOf: url) as? [String: String])
                XCTAssertTrue(strings.values.allSatisfy { !$0.isEmpty }, language)
                keySets[language] = Set(strings.keys)
            }
            let english = try XCTUnwrap(keySets["en"])
            XCTAssertGreaterThan(english.count, 40)
            for (language, keys) in keySets {
                XCTAssertEqual(keys, english, "\(language) differs from English")
            }
        }
    }
}
