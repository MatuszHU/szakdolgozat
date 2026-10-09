import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import Nightlife

@M9
final class InMemoryGuestPictureStore: ProfilePictureStoring {
    private(set) var data: Data?

    func load() -> Data? { data }
    func save(_ data: Data) throws { self.data = data }
    func delete() throws { data = nil }
}

extension Cucumber {

    @M8 @M9
    func setupGuestSettingsSteps() {
        var auth: AuthViewModel!
        var name: String?
        var settings: GuestSettingsViewModel!
        var store = InMemoryGuestPictureStore()
        var picture: ProfilePictureViewModel!

        func settingName(_ item: GuestSettingsItem) -> String {
            switch item {
            case .profilePicture: return "Profile picture"
            case .about: return "About"
            case .signOut: return "Sign out"
            }
        }

        func color(_ name: String) -> CGColor {
            name == "blue" ? CGColor(red: 0, green: 0, blue: 1, alpha: 1) : CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        }

        func photo(width: Int, height: Int, middle: CGColor, edges: CGColor? = nil) throws -> Data {
            let context = try XCTUnwrap(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                                  space: CGColorSpaceCreateDeviceRGB(),
                                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
            context.setFillColor(edges ?? middle)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            let side = min(width, height)
            context.setFillColor(middle)
            context.fill(CGRect(x: (width - side) / 2, y: (height - side) / 2, width: side, height: side))
            let image = try XCTUnwrap(context.makeImage())
            let data = NSMutableData()
            let destination = try XCTUnwrap(CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil))
            CGImageDestinationAddImage(destination, image, nil)
            XCTAssertTrue(CGImageDestinationFinalize(destination))
            return data as Data
        }

        func isColor(_ name: String) throws -> Bool {
            let average = try XCTUnwrap(ProfilePicture.averageColor(of: try XCTUnwrap(picture.imageData)))
            return name == "blue" ? average.blue > 0.9 && average.red < 0.1 : average.red > 0.9 && average.blue < 0.1
        }

        func openPicture() {
            if picture == nil { picture = ProfilePictureViewModel(store: store) }
        }

        BeforeScenario { _ in
            auth = nil
            name = nil
            settings = nil
            store = InMemoryGuestPictureStore()
            picture = nil
        }

        Given("the guest {string} is signed in to the settings") { match, _ in
            name = try match.first(\.string)
            auth = AuthViewModel(store: InMemoryCredentialStore())
            auth.signInWithApple(userID: "guest-apple-id")
            XCTAssertTrue(auth.isAuthenticated)
        }

        When("the guest opens the settings") { _, _ in
            settings = GuestSettingsViewModel(auth: auth, guestName: name)
        }

        When("the guest signs out in the settings") { _, _ in
            settings.signOut()
        }

        Then("the guest settings offer {string}") { match, _ in
            XCTAssertEqual(settings.items.map(settingName).joined(separator: ", "), try match.first(\.string))
        }

        Then("the about section says the guest is signed in as {string}") { match, _ in
            XCTAssertEqual(settings.guestName, try match.first(\.string))
        }

        Then("the about section shows the version of the guest app") { _, _ in
            XCTAssertFalse(settings.version.contains("?"))
        }

        Then("the guest app returns to the welcome screen") { _, _ in
            XCTAssertFalse(auth.isAuthenticated)
            XCTAssertTrue(auth.showWelcome)
        }

        Given("the guest chose a {string} photo as profile picture") { match, _ in
            openPicture()
            picture.choose(try photo(width: 800, height: 600, middle: color(try match.first(\.string))))
            XCTAssertNil(picture.errorMessage)
        }

        When("the guest chooses a photo of {int} by {int} pixels as profile picture") { match, _ in
            let size = try match.allParameters(\.int)
            openPicture()
            picture.choose(try photo(width: size[0], height: size[1], middle: color("blue"), edges: color("red")))
        }

        When("the guest chooses a {string} photo as profile picture") { match, _ in
            openPicture()
            picture.choose(try photo(width: 800, height: 600, middle: color(try match.first(\.string))))
        }

        When("the guest removes the profile picture") { _, _ in
            picture.remove()
        }

        When("the guest chooses a file that is not an image as profile picture") { _, _ in
            picture.choose(Data("not an image".utf8))
        }

        Then("the guest's profile picture is {int} by {int} pixels") { match, _ in
            let size = try match.allParameters(\.int)
            let data = try XCTUnwrap(picture.imageData)
            XCTAssertEqual(ProfilePicture.pixelSize(of: data), CGSize(width: size[0], height: size[1]))
            XCTAssertEqual(store.data, data)
        }

        Then("the guest's profile picture comes from the middle of the photo") { _, _ in
            XCTAssertTrue(try isColor("blue"))
        }

        Then("the guest's profile picture is {string}") { match, _ in
            XCTAssertTrue(try isColor(try match.first(\.string)))
        }

        Then("the guest has no profile picture") { _, _ in
            XCTAssertNil(picture.imageData)
            XCTAssertNil(store.data)
        }

        Then("the profile picture screen tells the guest {string}") { match, _ in
            XCTAssertEqual(english(picture.errorMessage), try match.first(\.string))
        }
    }
}
