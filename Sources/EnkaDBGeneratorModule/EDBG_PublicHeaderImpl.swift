// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension EnkaDBGenerator {
    public static func compileEnkaDB(
        for game: SupportedGame,
        targeting outputURL: URL,
        oneByOne: Bool = false,
        localPath: String? = nil
    ) async throws {
        printStderr("// =========================")
        printStderr("// Start writing EnkaDB json files for \(game.englishBrandName).")
        printStderr("// -------------------------")
        printStderr("// Proposed writing destination: \(outputURL.absoluteString)")
        printStderr("// -------------------------")
        let fileMgr = FileManager.default
        var isDirectory: ObjCBool = .init(booleanLiteral: false)
        let exists = fileMgr.fileExists(
            atPath: outputURL.path, isDirectory: &isDirectory
        )
        if exists, !isDirectory.boolValue {
            throw EDBGError.fileWritingAccessError(msg: "Destination is not a directory.")
        }
        if !exists {
            printStderr("// Target folder not exist. Attempting to create it.")
            try fileMgr.createDirectory(at: outputURL, withIntermediateDirectories: true)
            printStderr("// Target folder created successfully.")
            printStderr("// -------------------------")
        }
        // Folders prepared / confirmed. Proceeding.
        printStderr("// Start fetching files from Dimbreath's repository...")
        let theDB: DimDBProtocol = try await game.initDimDB(withLang: true, oneByOne: oneByOne, localPath: localPath)
        printStderr("// Succeeded in fetching files from Dimbreath's repository.")
        printStderr("// -------------------------")
        printStderr("// Start assembling EnkaDB JSON files.")
        let filesToRender = try theDB.packObjects()
        printStderr("// Succeeded in assembling EnkaDB JSON files. Exporting...")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        if await !Config.generateCondensedJSONFiles {
            encoder.outputFormatting.insert(.prettyPrinted)
            printStderr("// Assembling EnkaDB JSON files in minified format.")
        }
        try filesToRender.forEach { fileName, obj in
            let newURL = outputURL.appendingPathComponent(fileName).standardizedFileURL
            printStderr("// Writing to: \(newURL.absoluteString)")
            try encoder.encode(obj).write(to: newURL)
        }
        printStderr("// -------------------------")
        printStderr("// All tasks completed for writing EnkaDB json files for \(game.englishBrandName).")
        printStderr("// =========================")
    }

    public static func getEnkaDBEncodedJSONData(
        for game: SupportedGame,
        oneByOne: Bool = false,
        localPath: String? = nil
    ) async throws
        -> [String: Data] {
        printStderr("// Start fetching files from Dimbreath's repository...")
        let theDB: DimDBProtocol = try await game.initDimDB(withLang: true, oneByOne: oneByOne, localPath: localPath)
        printStderr("// Succeeded in fetching files from Dimbreath's repository.")
        printStderr("// -------------------------")
        printStderr("// Start assembling EnkaDB JSON files.")
        let filesToRender = try theDB.packObjects()
        printStderr("// Succeeded in assembling EnkaDB JSON files. Exporting...")
        let encoder = JSONEncoder()
        var container = [String: Data]()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try filesToRender.forEach { fileName, obj in
            try container[fileName] = encoder.encode(obj)
        }
        return container
    }
}
