// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnkaDBGenerator",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EnkaDBGeneratorModule",
            targets: ["EnkaDBGeneratorModule"]
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
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-warn-long-function-bodies=200",
                    "-Xfrontend",
                    "-warn-long-expression-type-checking=200",
                ]),
                // .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "EnkaDBModels",
            swiftSettings: [
                .unsafeFlags([
                    "-Xfrontend",
                    "-warn-long-function-bodies=100",
                    "-Xfrontend",
                    "-warn-long-expression-type-checking=100",
                ]),
                // .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "EnkaDBGeneratorTests",
            dependencies: ["EnkaDBGeneratorModule", "EnkaDBModels"]
        ),
    ]
)
