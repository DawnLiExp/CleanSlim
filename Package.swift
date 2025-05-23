// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "CleanSlim",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "CleanSlim",
            targets: ["CleanSlim"]),
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "CleanSlim",
            dependencies: [],
            resources: [
                .process("Resources"),
                .process("Localization"),
            ]),
    ])
