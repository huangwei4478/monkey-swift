// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MonkeySwift",
    products: [
        .executable(name: "MonkeySwift", targets: ["MonkeySwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "MonkeySwift",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "MonkeySwiftTests",
            dependencies: ["MonkeySwift"]),
    ]
)
