// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels
import Foundation

// MARK: - DimDBProtocol

protocol DimDBProtocol {
    var allNameTextMapHashes: Set<String> { get }
    static var targetGame: EnkaDBGenerator.SupportedGame { get }
    var langTable: [String: [String: String]] { get set }
    var avatarDBIdentifiable: [any NameHashable & IntegerIdentifiable] { get }
    init(withLang: Bool, oneByOne: Bool) async throws
    func packObjects() throws -> [String: any Encodable]
    mutating func bleach()
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

    private func getProtagonistTranslations() -> [Protagonist.DataPair] {
        let results: [Protagonist.DataPair] = avatarDBIdentifiable.compactMap { currentCharacter in
            let protagonist = Protagonist(rawValue: currentCharacter.id)
            guard let protagonist else { return Protagonist.DataPair?.none }
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

// MARK: - IntegerIdentifiable

protocol IntegerIdentifiable: Identifiable {
    var id: Int { get }
}

// MARK: - NameHashable

protocol NameHashable {
    var nameTextMapHash: Int { get }
}

extension Array where Element: NameHashable {
    /// This API is designed for bleaching dev-test contents left in the stable game versions.
    func bleached(
        against forbiddenNameTextMapHashes: Set<String>
    )
        -> [Element] {
        filter {
            !forbiddenNameTextMapHashes.contains($0.nameTextMapHash.description)
        }
    }
}

extension [String: [String: String]] {
    func findForbiddenNameTextMapHashes() -> Set<String> {
        let x: [[String]] = self.compactMap { langTag, langDict in
            guard ["en-us", "zh-cn"].contains(langTag) else { return nil }
            let y: [String] = langDict.compactMap { key, value in
                var matched = value.contains("(test)")
                matched = matched || value.contains("Test Skill")
                if langTag == "zh-cn" {
                    matched = matched || value.contains("测试")
                }
                guard matched else { return nil }
                return key
            }
            return y
        }
        return x.reduce(Set<String>()) { $0.union($1) }
    }
}
