// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnkaDBGenerator",
    platforms: [.macOS(.v10_15), .iOS(.v13), .watchOS(.v7)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EnkaDBGeneratorModule",
            targets: ["EnkaDBGeneratorModule"]
        ),
        .library(
            name: "EnkaDB",
            targets: ["EnkaDB"]
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
            name: "EnkaDBGeneratorModule"
        ),
        .target(
            name: "EnkaDB",
            dependencies: ["EnkaDBGeneratorModule"],
            resources: [
                // .process("Resources/OUTPUT-GI.json"),
                // .process("Resources/OUTPUT-HSR.json"),
            ]
        ),
        .testTarget(
            name: "EnkaDBGeneratorTests",
            dependencies: ["EnkaDBGeneratorModule"]
        ),
        .testTarget(
            name: "EnkaDBTests",
            dependencies: ["EnkaDB"]
        ),
    ]
)
