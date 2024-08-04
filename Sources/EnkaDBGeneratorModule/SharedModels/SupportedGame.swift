// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

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
            case "-hsr", "-sr", "sr", "hsr", "starrail": self = .starRail
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
    func initDimDB(withLang: Bool = true) async throws -> DimDBProtocol {
        switch self {
        case .genshinImpact: return try await DimModels4GI.DimDB4GI(withLang: withLang)
        case .starRail: return try await DimModels4HSR.DimDB4HSR(withLang: withLang)
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
        neededHashIDs: Set<String>
    ) async throws
        -> [String: [String: String]] {
        try await withThrowingTaskGroup(
            of: (subDict: [String: String], lang: EnkaDBGenerator.GameLanguage).self,
            returning: [String: [String: String]].self
        ) { taskGroup in
            #if DEBUG
            let langs = lang ?? [.langJP, .langEN, .langCHS]
            #else
            let langs = lang ?? EnkaDBGenerator.GameLanguage.allCases(for: self)
            #endif
            langs.forEach { locale in
                taskGroup.addTask {
                    let url = getLangDataURL(for: locale)
                    #if DEBUG
                    print("// Fetching: \(url.absoluteString)")
                    #endif
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
                    return (subDict: dict, lang: locale)
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
    func getLangDataURL(for lang: EnkaDBGenerator.GameLanguage) -> URL {
        URL(string: repoHeader + repoName + "TextMap/\(lang.filename)")!
    }

    // MARK: Private

    /// Only used for dealing with Dimbreath's repos.
    private var repoHeader: String {
        switch self {
        case .genshinImpact: return "https://gitlab.com/"
        case .starRail: return "https://raw.githubusercontent.com/"
        }
    }

    /// Only used for dealing with Dimbreath's repos.
    private var repoName: String {
        switch self {
        case .genshinImpact: return "Dimbreath/AnimeGameData/-/raw/master/"
        case .starRail: return "Dimbreath/StarRailData/master/"
        }
    }
}
