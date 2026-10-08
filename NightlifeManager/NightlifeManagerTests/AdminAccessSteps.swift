import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

@L1 @L3
final class InMemoryAdminDirectoryStore: AdminDirectoryPersisting, @unchecked Sendable {
    private(set) var saved: AdminDirectory?

    func load() -> AdminDirectory? { saved }

    func save(_ directory: AdminDirectory) throws {
        saved = directory
    }
}

@N8
@MainActor
func waitFor(_ operation: @escaping @MainActor () async -> Void) {
    var finished = false
    Task { @MainActor in
        await operation()
        finished = true
    }
    while !finished {
        RunLoop.main.run(until: Date().addingTimeInterval(0.005))
    }
}

extension Cucumber {

    @L1 @L2 @L3 @L5 @L6
    func setupAdminAccessSteps() {
        var viewModel: AdminSessionViewModel!
        var passwords: [String: String] = [:]

        @MainActor func freshSession() {
            let store = InMemoryAdminDirectoryStore()
            viewModel = AdminSessionViewModel(makeLocalBackend: {
                LocalAdminBackend(store: store, hasher: PBKDF2PasswordHasher(iterations: 1))
            })
            waitFor { await viewModel.load() }
            passwords = [:]
        }

        func role(_ text: String) -> AdminRole {
            switch text {
            case "owner": return .owner
            case "business manager": return .businessManager
            default: return .userAdmin
            }
        }

        @MainActor func admin(_ username: String) throws -> AdminUser {
            try XCTUnwrap(viewModel.snapshot.admins.first { $0.username == username }, "Unknown admin: \(username)")
        }

        @MainActor func signIn(_ username: String, _ password: String) {
            if viewModel.screen != .signIn { waitFor { await viewModel.signOut() } }
            waitFor { await viewModel.signIn(username: username, password: password) }
        }

        @MainActor func act(as username: String) throws {
            guard viewModel.currentAdmin?.username != username || viewModel.screen != .main else { return }
            signIn(username, try XCTUnwrap(passwords[username], "No known password for \(username)"))
            XCTAssertEqual(viewModel.screen, .main)
        }

        @MainActor func add(_ match: Match) throws {
            let texts = try match.allParameters(\.string)
            try act(as: texts[0])
            waitFor {
                await viewModel.addAdmin(name: texts[1], username: texts[2], role: role(texts[3]), temporaryPassword: texts[4])
            }
            if viewModel.errorMessage == nil { passwords[texts[2]] = texts[4] }
        }

        BeforeScenario { _ in
            MainActor.assumeIsolated { freshSession() }
        }

        setupCompanySettingsSteps { viewModel }

        Given("the admin app has no administrators yet") { _, _ in
            MainActor.assumeIsolated { XCTAssertEqual(viewModel.screen, .setup) }
        }

        Given("the owner {string} exists with the username {string} and the password {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            MainActor.assumeIsolated {
                waitFor { await viewModel.setUpOwner(name: texts[0], username: texts[1], password: texts[2]) }
                XCTAssertNil(viewModel.errorMessage)
                passwords[texts[1]] = texts[2]
                waitFor { await viewModel.signOut() }
            }
        }

        Given("the company domain is {string}") { match, _ in
            let domain = try match.first(\.string)
            try MainActor.assumeIsolated {
                try act(as: "anna")
                waitFor { await viewModel.setCompanyDomain(domain) }
                XCTAssertNil(viewModel.errorMessage)
            }
        }

        Given("{string} added {string} as {string} with the role {string} and the temporary password {string}") { match, _ in
            try MainActor.assumeIsolated {
                try add(match)
                XCTAssertNil(viewModel.errorMessage)
            }
        }

        Given("{string} has chosen the password {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            try MainActor.assumeIsolated {
                signIn(texts[0], try XCTUnwrap(passwords[texts[0]]))
                XCTAssertEqual(viewModel.screen, .changePassword)
                waitFor { await viewModel.chooseNewPassword(texts[1]) }
                passwords[texts[0]] = texts[1]
            }
        }

        MatchAll("{string} signs in with the password {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            MainActor.assumeIsolated { signIn(texts[0], texts[1]) }
        }

        When("the owner is set up as {string} with the username {string} and the password {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            MainActor.assumeIsolated {
                waitFor { await viewModel.setUpOwner(name: texts[0], username: texts[1], password: texts[2]) }
            }
        }

        When("the new password {string} is chosen") { match, _ in
            let password = try match.first(\.string)
            MainActor.assumeIsolated { waitFor { await viewModel.chooseNewPassword(password) } }
        }

        When("the administrator signs out") { _, _ in
            MainActor.assumeIsolated { waitFor { await viewModel.signOut() } }
        }

        When("{string} adds {string} as {string} with the role {string} and the temporary password {string}") { match, _ in
            try MainActor.assumeIsolated { try add(match) }
        }

        When("{string} resets the password of {string} to {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            try MainActor.assumeIsolated {
                try act(as: texts[0])
                let target = try admin(texts[1]).id
                waitFor { await viewModel.resetPassword(of: target, to: texts[2]) }
                XCTAssertNil(viewModel.errorMessage)
                passwords[texts[1]] = texts[2]
            }
        }

        When("{string} removes {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            try MainActor.assumeIsolated {
                try act(as: texts[0])
                let target = try admin(texts[1]).id
                waitFor { await viewModel.removeAdmin(id: target) }
            }
        }

        Then("{string} is signed in as owner") { match, _ in
            let name = try match.first(\.string)
            MainActor.assumeIsolated {
                XCTAssertEqual(viewModel.currentAdmin?.name, name)
                XCTAssertEqual(viewModel.currentAdmin?.role, .owner)
            }
        }

        Then("the main screen is shown") { _, _ in
            MainActor.assumeIsolated { XCTAssertEqual(viewModel.screen, .main) }
        }

        Then("the sign-in screen is shown") { _, _ in
            MainActor.assumeIsolated {
                XCTAssertEqual(viewModel.screen, .signIn)
                XCTAssertNil(viewModel.currentAdmin)
            }
        }

        Then("the sign-in screen shows {string}") { match, _ in
            let message = try match.first(\.string)
            MainActor.assumeIsolated {
                XCTAssertEqual(viewModel.screen, .signIn)
                XCTAssertEqual(viewModel.errorMessage, message)
            }
        }

        Then("the main screen shows {string}") { match, _ in
            let message = try match.first(\.string)
            MainActor.assumeIsolated {
                XCTAssertEqual(viewModel.screen, .main)
                XCTAssertEqual(viewModel.errorMessage, message)
            }
        }

        Then("a new password must be chosen") { _, _ in
            MainActor.assumeIsolated { XCTAssertEqual(viewModel.screen, .changePassword) }
        }

        Then("{string} can sign in with the password {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            MainActor.assumeIsolated {
                signIn(texts[0], texts[1])
                XCTAssertEqual(viewModel.screen, .main)
            }
        }

        Then("the e-mail address of {string} is {string} at {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            try MainActor.assumeIsolated {
                XCTAssertEqual(viewModel.email(of: try admin(texts[0])), texts[1] + "\u{40}" + texts[2])
            }
        }

        Then("the administrators are {string}") { match, _ in
            let expected = try match.first(\.string)
            MainActor.assumeIsolated {
                let listed = viewModel.snapshot.admins.map { "\($0.name) (\($0.role.displayName))" }
                XCTAssertEqual(listed.joined(separator: ", "), expected)
            }
        }
    }
}
