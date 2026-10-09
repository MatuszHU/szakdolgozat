import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeWorker

@K10
final class InMemoryProfilePictureStore: ProfilePictureStoring {
    private(set) var data: Data?

    func load() -> Data? { data }
    func save(_ data: Data) throws { self.data = data }
    func delete() throws { data = nil }
}

extension Cucumber {

    @K10
    func setupProfilePictureSteps() {
        var store = InMemoryProfilePictureStore()
        var viewModel: ProfilePictureViewModel!

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

        func open() {
            viewModel = ProfilePictureViewModel(store: store)
        }

        func isColor(_ name: String) throws -> Bool {
            let average = try XCTUnwrap(ProfilePicture.averageColor(of: try XCTUnwrap(viewModel.imageData)))
            return name == "blue" ? average.blue > 0.9 && average.red < 0.1 : average.red > 0.9 && average.blue < 0.1
        }

        BeforeScenario { _ in
            store = InMemoryProfilePictureStore()
            viewModel = nil
        }

        Given("I chose a {string} photo as my profile picture") { match, _ in
            open()
            viewModel.choose(try photo(width: 800, height: 600, middle: color(try match.first(\.string))))
            XCTAssertNil(viewModel.errorMessage)
        }

        When("I choose a photo of {int} by {int} pixels as my profile picture") { match, _ in
            let size = try match.allParameters(\.int)
            open()
            viewModel.choose(try photo(width: size[0], height: size[1], middle: color("blue"), edges: color("red")))
        }

        When("I choose a {string} photo as my profile picture") { match, _ in
            if viewModel == nil { open() }
            viewModel.choose(try photo(width: 800, height: 600, middle: color(try match.first(\.string))))
        }

        When("I remove my profile picture") { _, _ in
            viewModel.remove()
        }

        When("the profile picture screen is opened again") { _, _ in
            open()
        }

        When("I choose a file that is not an image as my profile picture") { _, _ in
            viewModel.choose(Data("not an image".utf8))
        }

        Then("my profile picture is {int} by {int} pixels") { match, _ in
            let size = try match.allParameters(\.int)
            let data = try XCTUnwrap(viewModel.imageData)
            XCTAssertEqual(ProfilePicture.pixelSize(of: data), CGSize(width: size[0], height: size[1]))
            XCTAssertEqual(store.data, data)
        }

        Then("my profile picture comes from the middle of the photo") { _, _ in
            XCTAssertTrue(try isColor("blue"))
        }

        Then("my profile picture is {string}") { match, _ in
            XCTAssertTrue(try isColor(try match.first(\.string)))
        }

        Then("I have no profile picture") { _, _ in
            XCTAssertNil(viewModel.imageData)
            XCTAssertNil(store.data)
        }

        Then("the profile picture screen says {string}") { match, _ in
            XCTAssertEqual(english(viewModel.errorMessage), try match.first(\.string))
        }
    }
}
