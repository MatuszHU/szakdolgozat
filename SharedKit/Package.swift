// swift-tools-version: 6.3

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SharedKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SharedKit",
            targets: ["SharedKit"]
        ),
        .library(
            name: "AdminCore",
            targets: ["AdminCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "604.0.0"..<"605.0.0"),
    ],
    targets: [
        .macro(
            name: "RequirementMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "Requirements",
            dependencies: ["RequirementMacros"]
        ),
        .target(
            name: "AdminCore",
            dependencies: ["Requirements"]
        ),
        .target(
            name: "SharedKit",
            dependencies: ["Requirements", "AdminCore"]
        ),
        .testTarget(
            name: "AdminCoreTests",
            dependencies: ["AdminCore", "Requirements"]
        ),
        .testTarget(
            name: "SharedKitTests",
            dependencies: ["SharedKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
