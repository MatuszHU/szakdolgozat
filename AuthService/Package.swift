// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AuthService",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(path: "../SharedKit"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "AdminCore", package: "SharedKit"),
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: ["App"]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "AdminCore", package: "SharedKit"),
            ]
        ),
    ]
)
