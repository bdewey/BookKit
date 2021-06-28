// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "BookKit",
            targets: ["BookKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/dehesa/CodableCSV.git", from: "0.6.6"),
    ],
    targets: [
        .target(
            name: "BookKit",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "CodableCSV",
            ]
        ),
        .testTarget(
            name: "BookKitTests",
            dependencies: ["BookKit"]
        ),
    ]
)
