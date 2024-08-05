// swift-tools-version: 5.10
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
            name: "EnkaDBFiles",
            targets: ["EnkaDBFiles"]
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
            resources: [
                .process("Resources/extra-loc-genshin.json"),
                .process("Resources/extra-loc-starrail.json"),
            ],
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
        .target(
            name: "EnkaDBFiles",
            dependencies: ["EnkaDBGeneratorModule"],
            resources: [
                .process("Resources/Specimen/GI/namecards.json"),
                .process("Resources/Specimen/GI/locs.json"),
                .process("Resources/Specimen/HSR/honker_ranks.json"),
                .process("Resources/Specimen/HSR/honker_skilltree.json"),
                .process("Resources/Specimen/GI/characters.json"),
                .process("Resources/Specimen/HSR/honker_meta.json"),
                .process("Resources/Specimen/HSR/hsr.json"),
                .process("Resources/Specimen/HSR/honker_skills.json"),
                .process("Resources/Specimen/HSR/honker_relics.json"),
                .process("Resources/Specimen/HSR/honker_avatars.json"),
                .process("Resources/Specimen/HSR/honker_characters.json"),
                .process("Resources/Specimen/HSR/honker_weps.json"),
                .process("Resources/Specimen/GI/pfps.json"),
            ],
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
            dependencies: ["EnkaDBGeneratorModule"]
        ),
        .testTarget(
            name: "EnkaDBFilesTests",
            dependencies: ["EnkaDBFiles"]
        ),
    ]
)
