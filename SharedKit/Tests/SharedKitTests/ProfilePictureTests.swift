import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Testing
@testable import SharedKit

@Suite("Profile picture")
@K10
struct ProfilePictureTests {

    private func png(width: Int, height: Int, leftColor: CGColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1),
                     rightColor: CGColor? = nil) throws -> Data {
        let context = try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.setFillColor(leftColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        if let rightColor {
            context.setFillColor(rightColor)
            context.fill(CGRect(x: width / 2, y: 0, width: width - width / 2, height: height))
        }
        let image = try #require(context.makeImage())
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return data as Data
    }

    @Test func aLargePhotoBecomesASquareOfTheMaximumSize() throws {
        let picture = try ProfilePicture.prepare(png(width: 2000, height: 1500))
        #expect(ProfilePicture.pixelSize(of: picture) == CGSize(width: 512, height: 512))
    }

    @Test func aSmallPhotoIsCroppedButNotEnlarged() throws {
        let picture = try ProfilePicture.prepare(png(width: 300, height: 400))
        #expect(ProfilePicture.pixelSize(of: picture) == CGSize(width: 300, height: 300))
    }

    @Test func theSquareIsCutFromTheMiddle() throws {
        let red = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        let blue = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        let picture = try ProfilePicture.prepare(png(width: 3000, height: 1000, leftColor: red, rightColor: blue))
        let left = try #require(ProfilePicture.averageColor(of: picture, inLeftHalf: true))
        let right = try #require(ProfilePicture.averageColor(of: picture, inLeftHalf: false))
        #expect(left.red > 0.9 && left.blue < 0.1)
        #expect(right.blue > 0.9 && right.red < 0.1)
    }

    @Test func theResultIsAJPEG() throws {
        let picture = try ProfilePicture.prepare(png(width: 100, height: 100))
        let source = try #require(CGImageSourceCreateWithData(picture as CFData, nil))
        #expect(CGImageSourceGetType(source) as String? == UTType.jpeg.identifier)
    }

    @Test func somethingThatIsNotAnImageIsRefused() {
        #expect(throws: ProfilePicture.PictureError.notAnImage) {
            try ProfilePicture.prepare(Data("hello".utf8))
        }
    }

    @Test func aHugeFileIsRefused() {
        #expect(throws: ProfilePicture.PictureError.tooLarge) {
            try ProfilePicture.prepare(Data(count: ProfilePicture.maximumFileSize + 1))
        }
    }
}
