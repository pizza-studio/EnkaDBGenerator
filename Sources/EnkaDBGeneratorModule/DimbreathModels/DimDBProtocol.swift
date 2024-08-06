// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - DimDBProtocol

protocol DimDBProtocol {
    var allNameTextMapHashes: Set<String> { get }
    static var targetGame: EnkaDBGenerator.SupportedGame { get }
    var langTable: [String: [String: String]] { get set }
    var avatarDBIdentifiable: [any IntegerIdentifiableWithLocHash] { get }
    init(withLang: Bool, oneByOne: Bool) async throws
    func packObjects() throws -> [String: any Encodable]
}

extension DimDBProtocol {
    mutating func updateLanguageMap(oneByOne: Bool = false) async throws {
        langTable = try await Self.targetGame.fetchRawLangData(
            neededHashIDs: allNameTextMapHashes, oneByOne: oneByOne
        )
        let protagonistTable = getProtagonistTranslations()
        protagonistTable.forEach { protagonist in
            for langTag in langTable.keys {
                let hashTxt = protagonist.nameHash.description
                langTable[langTag, default: [:]][hashTxt] = protagonist.dict[langTag]
            }
        }
    }

    private func getProtagonistTranslations() -> [EnkaDBGenerator.Protagonist.DataPair] {
        let results: [EnkaDBGenerator.Protagonist.DataPair] = avatarDBIdentifiable.compactMap { currentCharacter in
            let protagonist = EnkaDBGenerator.Protagonist(rawValue: currentCharacter.id)
            guard let protagonist else { return EnkaDBGenerator.Protagonist.DataPair?.none }
            return .init(
                avatarID: currentCharacter.id,
                nameHash: currentCharacter.nameTextMapHash,
                dict: protagonist.nameTranslationDict
            )
        }
        return results
    }

    func assembleEnkaLangMap() -> [String: [String: String]] {
        var enkaLangMap = [String: [String: String]]()
        langTable.forEach { dimLangTag, currentTable in
            let currentTable = currentTable
            guard let lang = EnkaDBGenerator.GameLanguage
                .allCases.first(where: { $0.langTag == dimLangTag }) else { return }
            enkaLangMap[lang.enkaLangID] = currentTable
        }
        Self.targetGame.extraLocMap.forEach { langKey, valTable in
            valTable.forEach { hash, valText in
                enkaLangMap[langKey, default: [:]][hash] = valText
            }
        }
        return enkaLangMap
    }
}

// MARK: - IntegerIdentifiableWithLocHash

protocol IntegerIdentifiableWithLocHash: Identifiable {
    var id: Int { get }
    var nameTextMapHash: Int { get }
}
