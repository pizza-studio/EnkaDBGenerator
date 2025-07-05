// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnkaDBGenerator",
    platforms: [.iOS(.v13), .macOS(.v10_15), .macCatalyst(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EnkaDBGeneratorModule",
            targets: ["EnkaDBGeneratorModule"]
        ),
        .library(
            name: "EnkaDBFiles",
            targets: ["EnkaDBFiles"]
        ),
        .library(
            name: "EnkaDBModels",
            targets: ["EnkaDBModels"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "EnkaDBGenerator",
            dependencies: [
                "EnkaDBGeneratorModule",
            ]
        ),
        .target(
            name: "EnkaDBGeneratorModule",
            dependencies: ["EnkaDBModels"],
            resources: [
                .process("Resources/extra-loc-genshin.json"),
                .process("Resources/extra-loc-starrail.json"),
            ],
            swiftSettings: []
        ),
        .target(
            name: "EnkaDBModels",
            swiftSettings: []
        ),
        .target(
            name: "EnkaDBFiles",
            dependencies: [],
            resources: [
                .process("Resources/"),
            ],
            swiftSettings: []
        ),
        .testTarget(
            name: "EnkaDBGeneratorTests",
            dependencies: ["EnkaDBGeneratorModule", "EnkaDBModels"]
        ),
        .testTarget(
            name: "EnkaDBFilesTests",
            dependencies: ["EnkaDBFiles", "EnkaDBModels"]
        ),
    ]
)
