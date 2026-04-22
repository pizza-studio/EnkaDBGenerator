// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - EnkaDBGenerator.SupportedGame

extension EnkaDBGenerator {
    public enum SupportedGame: CaseIterable, Sendable {
        case genshinImpact
        case starRail

        // MARK: Lifecycle

        /// Initialize this enum using given commandline argument.
        public init?(arg: String) {
            switch arg.lowercased() {
            case "-gi", "genshin", "genshinimpact", "gi": self = .genshinImpact
            case "-hsr", "-sr", "hsr", "sr", "starrail": self = .starRail
            default: return nil
            }
        }

        // MARK: Public

        public var englishBrandName: String {
            switch self {
            case .genshinImpact: return "Genshin Impact"
            case .starRail: return "Star Rail"
            }
        }
    }
}

// MARK: - DimDB Initializer.

extension EnkaDBGenerator.SupportedGame {
    func initDimDB(withLang: Bool = true, oneByOne: Bool, localPath: String? = nil) async throws -> DimDBProtocol {
        switch self {
        case .genshinImpact:
            return try await DimModels4GI.DimDB4GI(withLang: withLang, oneByOne: oneByOne, localPath: localPath)
        case .starRail:
            return try await DimModels4HSR.DimDB4HSR(withLang: withLang, oneByOne: oneByOne, localPath: localPath)
        }
    }
}

// MARK: - Extra Loc Map.

extension EnkaDBGenerator.SupportedGame {
    private var extraLocDictFileName: String {
        switch self {
        case .genshinImpact: return "extra-loc-genshin"
        case .starRail: return "extra-loc-starrail"
        }
    }

    var extraLocMap: [String: [String: String]] {
        let url = Bundle.module.url(forResource: extraLocDictFileName, withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([String: [String: String]].self, from: data)
            return decoded.reduce(into: [String: [String: String]]()) { partialResult, entry in
                partialResult[entry.key] = entry.value.mapValues {
                    sanitizeTextMapValue($0, enkaLangID: entry.key)
                }
            }
        } catch {
            print(error.localizedDescription)
            return [:]
        }
    }

    func sanitizeTextMapValue(_ value: String, lang: EnkaDBGenerator.GameLanguage) -> String {
        sanitizeTextMapValue(
            value,
            stripsRubyMarkup: lang == .langJP
        )
    }

    func sanitizeTextMapValue(_ value: String, enkaLangID: String) -> String {
        sanitizeTextMapValue(
            value,
            stripsRubyMarkup: enkaLangID == EnkaDBGenerator.GameLanguage.langJP.enkaLangID
        )
    }

    private func sanitizeTextMapValue(_ value: String, stripsRubyMarkup: Bool) -> String {
        guard self == .starRail else { return value }
        var sanitized = value
        if stripsRubyMarkup, sanitized.contains("{RUBY"), sanitized.contains("{") {
            sanitized = sanitized.replacingOccurrences(
                of: #"\{RUBY.*?\}"#,
                with: "",
                options: .regularExpression
            )
        }
        if sanitized.contains("<unbreak>") || sanitized.contains("</unbreak>") {
            sanitized = sanitized.replacingOccurrences(of: "<unbreak>", with: "")
            sanitized = sanitized.replacingOccurrences(of: "</unbreak>", with: "")
        }
        return sanitized
    }
}

// MARK: - Dealing with data from Dimbreath's Repository.

extension EnkaDBGenerator.SupportedGame {
    /// Only used for dealing with Dimbreath's repos.
    func fetchRawLangData(
        lang: [EnkaDBGenerator.GameLanguage]? = nil,
        neededHashIDs: Set<String>,
        oneByOne: Bool = false,
        localPath: String? = nil
    ) async throws
        -> [String: [String: String]] {
        guard !oneByOne else {
            return try await fetchRawLangData1By1(
                lang: lang, neededHashIDs: neededHashIDs, localPath: localPath
            )
        }
        func decodeLangDict(_ data: Data, url: URL) throws -> [String: String] {
            do {
                return try JSONDecoder().decode([String: String].self, from: data)
            } catch let decodingError as DecodingError {
                printStderr("// Decoding failed for: \(url.absoluteString)")
                throw decodingError
            }
        }
        return try await withThrowingTaskGroup(
            of: (subDict: [String: String], lang: EnkaDBGenerator.GameLanguage).self,
            returning: [String: [String: String]].self
        ) { taskGroup in
            #if DEBUG
            printStderr("// ------------------------")
            printStderr("// This program is compiled as a debug build, therefore ..")
            printStderr("// .. the localization data are gonna fetched for the following languages only:")
            printStderr("// [ja-JP] [zh-Hans] [en-US].")
            printStderr("// ------------------------")
            let langs = lang ?? [.langJP, .langEN, .langCHS]
            #else
            printStderr("// ------------------------")
            printStderr("// Fetching the localization data for all supported languages.")
            printStderr("// ------------------------")
            let langs = lang ?? EnkaDBGenerator.GameLanguage.allCases(for: self)
            #endif
            langs.forEach { locale in
                taskGroup.addTask {
                    let urls = self.getLangDataURLs(for: locale, localPath: localPath)
                    var finalDict = [String: String]()
                    for url in urls {
                        let data: Data
                        if url.isFileURL {
                            printStderr("// Reading local: \(url.path)")
                            data = try Data(contentsOf: url)
                        } else {
                            printStderr("// Fetching: \(url.absoluteString)")
                            let (d, _) = try await URLSession.shared.asyncData(from: url)
                            data = d
                        }
                        var dict = try decodeLangDict(data, url: url)
                        let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
                        keysToRemove.forEach { dict.removeValue(forKey: $0) }
                        dict = dict.mapValues { sanitizeTextMapValue($0, lang: locale) }
                        dict.forEach { key, value in
                            finalDict[key] = value
                        }
                    }
                    return (subDict: finalDict, lang: locale)
                }
            }
            var results = [String: [String: String]]()
            for try await result in taskGroup {
                results[result.lang.langTag] = result.subDict
            }
            return results
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    ///
    /// This API does the tasks one-by-one.
    func fetchRawLangData1By1(
        lang: [EnkaDBGenerator.GameLanguage]? = nil,
        neededHashIDs: Set<String>,
        localPath: String? = nil
    ) async throws
        -> [String: [String: String]] {
        var resultBuffer = [String: [String: String]]()
        func decodeLangDict(_ data: Data, url: URL) throws -> [String: String] {
            do {
                return try JSONDecoder().decode([String: String].self, from: data)
            } catch let decodingError as DecodingError {
                printStderr("// Decoding failed for: \(url.absoluteString)")
                throw decodingError
            }
        }
        #if DEBUG
        printStderr("// ------------------------")
        printStderr("// This program is compiled as a debug build, therefore ..")
        printStderr("// .. the localization data are gonna fetched for the following languages only:")
        printStderr("// [ja-JP] [zh-Hans] [en-US].")
        printStderr("// ------------------------")
        let langs = lang ?? [.langJP, .langEN, .langCHS]
        #else
        printStderr("// ------------------------")
        printStderr("// Fetching the localization data for all supported languages.")
        printStderr("// ------------------------")
        let langs = lang ?? EnkaDBGenerator.GameLanguage.allCases(for: self)
        #endif
        for locale in langs {
            let urls = getLangDataURLs(for: locale, localPath: localPath)
            var finalDict = [String: String]()
            for url in urls {
                let data: Data
                if url.isFileURL {
                    printStderr("// Reading local: \(url.path)")
                    data = try Data(contentsOf: url)
                } else {
                    printStderr("// Fetching: \(url.absoluteString)")
                    let (d, _) = try await URLSession.shared.asyncData(from: url)
                    data = d
                }
                var dict = try decodeLangDict(data, url: url)
                let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
                keysToRemove.forEach { dict.removeValue(forKey: $0) }
                dict = dict.mapValues { sanitizeTextMapValue($0, lang: locale) }
                dict.forEach { key, value in
                    finalDict[key] = value
                }
            }
            let result = (subDict: finalDict, lang: locale)
            resultBuffer[result.lang.langTag] = result.subDict
        }
        return resultBuffer
    }

    /// Only used for dealing with Dimbreath's repos.
    func getLangDataURLs(for lang: EnkaDBGenerator.GameLanguage, localPath: String? = nil) -> [URL] {
        lang.filenamesForChunks(for: self).map { filename in
            if let localPath {
                return URL(fileURLWithPath: localPath)
                    .appendingPathComponent("TextMap")
                    .appendingPathComponent(filename)
            }
            return URL(string: repoHeader + repoName + "TextMap/\(filename)")!
        }
    }

    // MARK: Private

    /// Only used for dealing with Dimbreath's repos.
    private var repoHeader: String {
        switch self {
        case .genshinImpact: return "https://raw.githubusercontent.com/"
        case .starRail: return "https://raw.githubusercontent.com/"
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    private var repoName: String {
        switch self {
        case .genshinImpact: return "DimbreathBot/AnimeGameData/refs/heads/master/"
        case .starRail: return "DimbreathBot/TurnBasedGameData/refs/heads/main/"
        }
    }
}
