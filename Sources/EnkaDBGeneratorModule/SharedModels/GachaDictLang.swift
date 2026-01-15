// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - EnkaDBGenerator.GameLanguage

extension EnkaDBGenerator {
    public enum GameLanguage: String, CaseIterable, Sendable, Identifiable {
        case langCHS
        case langCHT
        case langDE
        case langEN
        case langES
        case langFR
        case langID
        case langIT
        case langJP
        case langKR
        case langPT
        case langRU
        case langTH
        case langTR
        case langVI

        // MARK: Public

        public var id: String { langTag }

        // MARK: Internal

        var langTag: String {
            switch self {
            case .langCHS: "zh-cn"
            case .langCHT: "zh-tw"
            case .langDE: "de-de"
            case .langEN: "en-us"
            case .langES: "es-es"
            case .langFR: "fr-fr"
            case .langID: "id-id"
            case .langIT: "it-it"
            case .langJP: "ja-jp"
            case .langKR: "ko-kr"
            case .langPT: "pt-pt"
            case .langRU: "ru-ru"
            case .langTH: "th-th"
            case .langTR: "tr-tr"
            case .langVI: "vi-vn"
            }
        }

        var filename: String {
            rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending(".json")
        }

        var enkaLangID: String {
            switch self {
            case .langCHS, .langCHT: return langTag
            default: return langTag.split(separator: "-")[0].description
            }
        }

        static func allCases(for game: EnkaDBGenerator.SupportedGame) -> [Self] {
            switch game {
            case .genshinImpact: return casesForGenshin
            case .starRail: return casesForHSR
            }
        }

        func filenamesForChunks(for game: EnkaDBGenerator.SupportedGame) -> [String] {
            guard game == .genshinImpact else { return [filename] }
            return switch self {
            case .langTH, .langRU: [
                    rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending("_0.json"),
                    rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending("_1.json"),
                ]
            default: [filename]
            }
        }

        // MARK: Private

        private static let casesForGenshin: [Self] = Self.allCases

        private static let casesForHSR: [Self] = Self.allCases.filter {
            ![Self.langIT, Self.langTR].contains($0)
        }
    }
}

// MARK: - Optional + CaseIterable

extension Optional where Wrapped == EnkaDBGenerator.GameLanguage {
    public static var allCases: [EnkaDBGenerator.GameLanguage?] {
        EnkaDBGenerator.GameLanguage.allCases + [Self.none]
    }

    static func allCases(for game: EnkaDBGenerator.SupportedGame) -> [Self] {
        EnkaDBGenerator.GameLanguage.allCases(for: game) + [Self.none]
    }
}
