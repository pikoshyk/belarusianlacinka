// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BelarusianLacinka",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4), .macCatalyst(.v13)],
    products: [
        .library(
            name: "BelarusianLacinka",
            targets: ["BelarusianLacinka"]),
    ],
    targets: [
        .target(
            name: "BelarusianLacinka",
            dependencies: [],
            resources: [.process("Resources")]),
    ]
)
