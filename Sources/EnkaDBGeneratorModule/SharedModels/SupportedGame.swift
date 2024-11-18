// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - EnkaDBGenerator.SupportedGame

extension EnkaDBGenerator {
    public enum SupportedGame: CaseIterable {
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
    func initDimDB(withLang: Bool = true, oneByOne: Bool) async throws -> DimDBProtocol {
        switch self {
        case .genshinImpact:
            return try await DimModels4GI.DimDB4GI(withLang: withLang, oneByOne: oneByOne)
        case .starRail:
            return try await DimModels4HSR.DimDB4HSR(withLang: withLang, oneByOne: oneByOne)
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
            return decoded
        } catch {
            print(error.localizedDescription)
            return [:]
        }
    }
}

// MARK: - Dealing with data from Dimbreath's Repository.

extension EnkaDBGenerator.SupportedGame {
    /// Only used for dealing with Dimbreath's repos.
    func fetchRawLangData(
        lang: [EnkaDBGenerator.GameLanguage]? = nil,
        neededHashIDs: Set<String>,
        oneByOne: Bool = false
    ) async throws
        -> [String: [String: String]] {
        guard !oneByOne else {
            return try await fetchRawLangData1By1(lang: lang, neededHashIDs: neededHashIDs)
        }
        return try await withThrowingTaskGroup(
            of: (subDict: [String: String], lang: EnkaDBGenerator.GameLanguage).self,
            returning: [String: [String: String]].self
        ) { taskGroup in
            #if DEBUG
            print("// ------------------------")
            print("// This program is compiled as a debug build, therefore ..")
            print("// .. the localization data are gonna fetched for the following languages only:")
            print("// [ja-JP] [zh-Hans] [en-US].")
            print("// ------------------------")
            let langs = lang ?? [.langJP, .langEN, .langCHS]
            #else
            print("// ------------------------")
            print("// Fetching the localization data for all supported languages.")
            print("// ------------------------")
            let langs = lang ?? EnkaDBGenerator.GameLanguage.allCases(for: self)
            #endif
            langs.forEach { locale in
                taskGroup.addTask {
                    let urls = getLangDataURLs(for: locale)
                    var finalDict = [String: String]()
                    for url in urls {
                        print("// Fetching: \(url.absoluteString)")
                        let (data, _) = try await URLSession.shared.asyncData(from: url)
                        var dict = try JSONDecoder().decode([String: String].self, from: data)
                        let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
                        keysToRemove.forEach { dict.removeValue(forKey: $0) }
                        if locale == .langJP {
                            dict.keys.forEach { theKey in
                                guard dict[theKey]?.contains("{RUBY") ?? false else { return }
                                if let rawStrToHandle = dict[theKey], rawStrToHandle.contains("{") {
                                    dict[theKey] = rawStrToHandle.replacingOccurrences(
                                        of: #"\{RUBY.*?\}"#,
                                        with: "",
                                        options: .regularExpression
                                    )
                                }
                            }
                        }
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
        neededHashIDs: Set<String>
    ) async throws
        -> [String: [String: String]] {
        var resultBuffer = [String: [String: String]]()
        #if DEBUG
        print("// ------------------------")
        print("// This program is compiled as a debug build, therefore ..")
        print("// .. the localization data are gonna fetched for the following languages only:")
        print("// [ja-JP] [zh-Hans] [en-US].")
        print("// ------------------------")
        let langs = lang ?? [.langJP, .langEN, .langCHS]
        #else
        print("// ------------------------")
        print("// Fetching the localization data for all supported languages.")
        print("// ------------------------")
        let langs = lang ?? EnkaDBGenerator.GameLanguage.allCases(for: self)
        #endif
        for locale in langs {
            let urls = getLangDataURLs(for: locale)
            var finalDict = [String: String]()
            for url in urls {
                print("// Fetching: \(url.absoluteString)")
                let (data, _) = try await URLSession.shared.asyncData(from: url)
                var dict = try JSONDecoder().decode([String: String].self, from: data)
                let keysToRemove = Set<String>(dict.keys).subtracting(neededHashIDs)
                keysToRemove.forEach { dict.removeValue(forKey: $0) }
                if locale == .langJP {
                    dict.keys.forEach { theKey in
                        guard dict[theKey]?.contains("{RUBY") ?? false else { return }
                        if let rawStrToHandle = dict[theKey], rawStrToHandle.contains("{") {
                            dict[theKey] = rawStrToHandle.replacingOccurrences(
                                of: #"\{RUBY.*?\}"#,
                                with: "",
                                options: .regularExpression
                            )
                        }
                    }
                }
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
    func getLangDataURLs(for lang: EnkaDBGenerator.GameLanguage) -> [URL] {
        lang.filenamesForChunks(for: self).map { filename in
            URL(string: repoHeader + repoName + "TextMap/\(filename)")!
        }
    }

    // MARK: Private

    /// Only used for dealing with Dimbreath's repos.
    private var repoHeader: String {
        switch self {
        case .genshinImpact: return "https://gitlab.com/"
        case .starRail: return "https://gitlab.com/"
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    private var repoName: String {
        switch self {
        case .genshinImpact: return "Dimbreath/AnimeGameData/-/raw/master/"
        case .starRail: return "Dimbreath/TurnBasedGameData/-/raw/main/"
        }
    }
}
