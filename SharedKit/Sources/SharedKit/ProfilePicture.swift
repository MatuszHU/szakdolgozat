import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

@K10
public enum ProfilePicture {
    public enum PictureError: Error, Equatable {
        case notAnImage
        case tooLarge
    }

    public struct Color: Equatable {
        public let red: Double
        public let green: Double
        public let blue: Double
    }

    public static let maximumPixelSize = 512
    public static let maximumFileSize = 20 * 1024 * 1024

    public static func prepare(_ data: Data) throws -> Data {
        guard data.count <= maximumFileSize else { throw PictureError.tooLarge }
        guard let image = orientedImage(from: data) else { throw PictureError.notAnImage }
        let side = min(image.width, image.height)
        let square = CGRect(x: (image.width - side) / 2, y: (image.height - side) / 2, width: side, height: side)
        guard let cropped = image.cropping(to: square) else { throw PictureError.notAnImage }
        let size = min(side, maximumPixelSize)
        guard let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            throw PictureError.notAnImage
        }
        context.interpolationQuality = .high
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let scaled = context.makeImage() else { throw PictureError.notAnImage }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw PictureError.notAnImage
        }
        CGImageDestinationAddImage(destination, scaled, [kCGImageDestinationLossyCompressionQuality: 0.85] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw PictureError.notAnImage }
        return output as Data
    }

    public static func pixelSize(of data: Data) -> CGSize? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return CGSize(width: image.width, height: image.height)
    }

    public static func averageColor(of data: Data, inLeftHalf leftHalf: Bool? = nil) -> Color? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        let width = image.width, height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                                          bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        let columns = leftHalf.map { $0 ? 0..<(width / 2) : (width - width / 2)..<width } ?? 0..<width
        var red = 0.0, green = 0.0, blue = 0.0, count = 0.0
        for row in 0..<height {
            for column in columns {
                let offset = (row * width + column) * 4
                red += Double(pixels[offset])
                green += Double(pixels[offset + 1])
                blue += Double(pixels[offset + 2])
                count += 1
            }
        }
        guard count > 0 else { return nil }
        return Color(red: red / count / 255, green: green / count / 255, blue: blue / count / 255)
    }

    private static func orientedImage(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 0,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: max(width, height),
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}
