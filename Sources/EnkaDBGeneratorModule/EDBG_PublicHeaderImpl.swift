// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

extension EnkaDBGenerator {
    public func compileEnkaDB(for game: SupportedGame, targeting outputURL: URL) async throws {
        print("// =========================")
        print("// Start writing EnkaDB json files for \(game.englishBrandName).")
        print("// -------------------------")
        print("// Proposed writing destination: \(outputURL.absoluteString).")
        print("// -------------------------")
        let fileMgr = FileManager.default
        var isDirectory: ObjCBool = .init(booleanLiteral: false)
        let exists = fileMgr.fileExists(
            atPath: outputURL.path(percentEncoded: false), isDirectory: &isDirectory
        )
        if exists, !isDirectory.boolValue {
            throw EDBGError.fileWritingAccessError(msg: "Destination is not a directory.")
        }
        if !exists {
            print("// Target folder not exist. Attempting to create it.")
            try fileMgr.createDirectory(at: outputURL, withIntermediateDirectories: true)
            print("// Target folder created successfully.")
            print("// -------------------------")
        }
        // Folders prepared / confirmed. Proceeding.
        print("// Start fetching files from Dimbreath's repository...")
        let theDB: DimDBProtocol = try await game.initDimDB(withLang: true)
        print("// Succeeded in fetching files from Dimbreath's repository.")
        print("// -------------------------")
        print("// Start assembling EnkaDB JSON files.")
        let filesToRender = try theDB.packObjects()
        print("// Succeeded in assembling EnkaDB JSON files. Exporting...")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try filesToRender.forEach { fileName, obj in
            let newURL = outputURL.appending(path: fileName, directoryHint: .notDirectory).standardizedFileURL
            print("// Writing to: \(newURL.absoluteString)")
            try encoder.encode(obj).write(to: newURL)
        }
        print("// -------------------------")
        print("// All tasks completed for writing EnkaDB json files for \(game.englishBrandName).")
        print("// =========================")
    }
}
