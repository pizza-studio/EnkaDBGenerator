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
        fputs("// =========================\n", stderr)
        fputs("// Start writing EnkaDB json files for \(game.englishBrandName).\n", stderr)
        fputs("// -------------------------\n", stderr)
        fputs("// Proposed writing destination: \(outputURL.absoluteString)\n", stderr)
        fputs("// -------------------------\n", stderr)
        let fileMgr = FileManager.default
        var isDirectory: ObjCBool = .init(booleanLiteral: false)
        let exists = fileMgr.fileExists(
            atPath: outputURL.path, isDirectory: &isDirectory
        )
        if exists, !isDirectory.boolValue {
            throw EDBGError.fileWritingAccessError(msg: "Destination is not a directory.")
        }
        if !exists {
            fputs("// Target folder not exist. Attempting to create it.\n", stderr)
            try fileMgr.createDirectory(at: outputURL, withIntermediateDirectories: true)
            fputs("// Target folder created successfully.\n", stderr)
            fputs("// -------------------------\n", stderr)
        }
        // Folders prepared / confirmed. Proceeding.
        fputs("// Start fetching files from Dimbreath's repository...\n", stderr)
        let theDB: DimDBProtocol = try await game.initDimDB(withLang: true, oneByOne: oneByOne, localPath: localPath)
        fputs("// Succeeded in fetching files from Dimbreath's repository.\n", stderr)
        fputs("// -------------------------\n", stderr)
        fputs("// Start assembling EnkaDB JSON files.\n", stderr)
        let filesToRender = try theDB.packObjects()
        fputs("// Succeeded in assembling EnkaDB JSON files. Exporting...\n", stderr)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        if await !Config.generateCondensedJSONFiles {
            encoder.outputFormatting.insert(.prettyPrinted)
            fputs("// Assembling EnkaDB JSON files in minified format.\n", stderr)
        }
        try filesToRender.forEach { fileName, obj in
            let newURL = outputURL.appendingPathComponent(fileName).standardizedFileURL
            fputs("// Writing to: \(newURL.absoluteString)\n", stderr)
            try encoder.encode(obj).write(to: newURL)
        }
        fputs("// -------------------------\n", stderr)
        fputs("// All tasks completed for writing EnkaDB json files for \(game.englishBrandName).\n", stderr)
        fputs("// =========================\n", stderr)
    }

    public static func getEnkaDBEncodedJSONData(
        for game: SupportedGame,
        oneByOne: Bool = false,
        localPath: String? = nil
    ) async throws
        -> [String: Data] {
        fputs("// Start fetching files from Dimbreath's repository...\n", stderr)
        let theDB: DimDBProtocol = try await game.initDimDB(withLang: true, oneByOne: oneByOne, localPath: localPath)
        fputs("// Succeeded in fetching files from Dimbreath's repository.\n", stderr)
        fputs("// -------------------------\n", stderr)
        fputs("// Start assembling EnkaDB JSON files.\n", stderr)
        let filesToRender = try theDB.packObjects()
        fputs("// Succeeded in assembling EnkaDB JSON files. Exporting...\n", stderr)
        let encoder = JSONEncoder()
        var container = [String: Data]()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try filesToRender.forEach { fileName, obj in
            try container[fileName] = encoder.encode(obj)
        }
        return container
    }
}
