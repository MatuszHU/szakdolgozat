import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

@K11
final class InMemoryLanguageStore: LanguageStoring {
    private(set) var saved: AppLanguage?

    func load() -> AppLanguage? { saved }
    func save(_ language: AppLanguage) { saved = language }
}

extension Cucumber {

    @K11
    func setupLanguageSteps() {
        var store = InMemoryLanguageStore()
        var settings: LanguageSettings!

        func language(_ code: String) throws -> AppLanguage {
            try XCTUnwrap(AppLanguage(rawValue: code), "Unknown language in scenario: \(code)")
        }

        func homeItem(_ name: String) throws -> HomeItem {
            switch name {
            case "Schedule": return .schedule
            case "Notifications": return .notifications
            default: throw UnknownScenarioName(name: name)
            }
        }

        func choose(_ match: Match) throws {
            if settings == nil { settings = LanguageSettings(store: store, supported: AppLanguage.worker) }
            settings.choose(try language(try match.first(\.string)))
        }

        func compiledStrings(_ localization: String) throws -> [String: String] {
            let url = try XCTUnwrap(Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil,
                                                    localization: localization), "No \(localization) strings")
            return try XCTUnwrap(NSDictionary(contentsOf: url) as? [String: String])
        }

        BeforeScenario { _ in
            store = InMemoryLanguageStore()
            settings = nil
        }

        Given("I chose {string} as the language") { match, _ in
            try choose(match)
        }

        When("I choose {string} as the language") { match, _ in
            try choose(match)
        }

        When("I open the language settings") { _, _ in
            settings = LanguageSettings(store: store, supported: AppLanguage.worker)
        }

        When("the language settings are opened again") { _, _ in
            settings = LanguageSettings(store: store, supported: AppLanguage.worker)
        }

        Then("the chosen language is {string}") { match, _ in
            XCTAssertEqual(settings.language, try language(try match.first(\.string)))
        }

        Then("the home screen item {string} reads {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            XCTAssertEqual(settings.text(try homeItem(texts[0]).title), texts[1])
        }

        Then("the supply request confirmation reads {string}") { match, _ in
            XCTAssertEqual(settings.text("Request sent"), try match.first(\.string))
        }

        Then("every text of the app has a Hungarian, an English and a Portuguese version") { _, _ in
            let hungarian = try compiledStrings("hu")
            let english = try compiledStrings("en")
            let portuguese = try compiledStrings("pt-PT")
            XCTAssertGreaterThan(english.count, 50)
            XCTAssertEqual(Set(hungarian.keys), Set(english.keys))
            XCTAssertEqual(Set(portuguese.keys), Set(english.keys))
            for strings in [hungarian, english, portuguese] {
                XCTAssertTrue(strings.values.allSatisfy { !$0.isEmpty })
            }
            XCTAssertEqual(english["Beállítások"], "Settings")
            XCTAssertEqual(portuguese["Beállítások"], "Definições")
        }
    }
}
