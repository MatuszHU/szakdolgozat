import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

extension Cucumber {

    @K9 @K15
    func setupSettingsSteps() {
        var auth: AuthViewModel!
        var name: String?
        var settings: SettingsViewModel!
        var guide: GuideViewModel!

        func settingName(_ item: SettingsItem) -> String {
            switch item {
            case .profilePicture: return "Profile picture"
            case .language: return "Language"
            case .guide: return "Guide"
            case .about: return "About"
            case .signOut: return "Sign out"
            }
        }

        func topicName(_ topic: GuideTopic) -> String {
            switch topic {
            case .settings: return "Settings"
            case .home(let item):
                switch item {
                case .schedule: return "Schedule"
                case .notifications: return "Notifications"
                case .codeReader: return "Code reader"
                case .map: return "Map"
                case .supplyRequest: return "Supply request"
                case .summary: return "Summary"
                }
            }
        }

        BeforeScenario { _ in
            auth = nil
            name = nil
            settings = nil
            guide = nil
        }

        Given("the worker {string} is signed in") { match, _ in
            name = try match.first(\.string)
            auth = AuthViewModel(store: InMemoryCredentialStore())
            auth.signInWithApple(userID: "worker-apple-id")
            XCTAssertTrue(auth.isAuthenticated)
        }

        When("I open the settings") { _, _ in
            settings = SettingsViewModel(auth: auth, workerName: name, enabledFeatures: World.enabledFeatures)
        }

        When("I sign out in the settings") { _, _ in
            settings.signOut()
        }

        When("I open the guide") { _, _ in
            guide = GuideViewModel(menu: HomeMenuViewModel(enabledFeatures: World.enabledFeatures))
        }

        Then("the settings offer {string}") { match, _ in
            XCTAssertEqual(settings.items.map(settingName).joined(separator: ", "), try match.first(\.string))
        }

        Then("the about section says I am signed in as {string}") { match, _ in
            XCTAssertEqual(settings.workerName, try match.first(\.string))
        }

        Then("the about section shows the version of the app") { _, _ in
            XCTAssertFalse(settings.version.contains("?"))
        }

        Then("the app returns to the welcome screen") { _, _ in
            XCTAssertFalse(auth.isAuthenticated)
            XCTAssertTrue(auth.showWelcome)
        }

        Then("the guide has the sections {string}") { match, _ in
            XCTAssertEqual(guide.sections.map { topicName($0.topic) }.joined(separator: ", "), try match.first(\.string))
            XCTAssertTrue(guide.sections.allSatisfy { !(english($0.text) ?? "").isEmpty })
        }
    }
}
