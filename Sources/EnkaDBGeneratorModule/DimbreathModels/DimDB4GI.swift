// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

// MARK: - DimModels4GI.DimDB4GI

extension DimModels4GI {
    struct DimDB4GI {
        // MARK: Lifecycle

        init(withLang: Bool = true) async throws {
            let dataStack: [DimModels4GI: Data] = try await getDataStack()
            let decoder = JSONDecoder()
            self.avatarDB = try decoder.decode(
                [AvatarExcelConfigData].self,
                from: dataStack[.avatar]!
            ).filter(\.isValid)
            self.skillDB = try decoder.decode(
                [AvatarSkillExcelConfigData].self,
                from: dataStack[.skill]!
            ).filter(\.isValid)
            self.constellationDB = try decoder.decode(
                [AvatarTalentExcelConfigData].self,
                from: dataStack[.constellation]!
            )
            self.artifactDB = try decoder.decode(
                [ReliquaryExcelConfigData].self,
                from: dataStack[.artifact]!
            )
            self.artifactSetDB = try decoder.decode(
                [EquipAffixExcelConfigData].self,
                from: dataStack[.artifactSet]!
            ).filter(\.isValid)
            self.artifactMainPropDB = try decoder.decode(
                [ReliquaryMainPropExcelConfigData].self,
                from: dataStack[.artifactMainProp]!
            )
            self.artifactSubPropDB = try decoder.decode(
                [ReliquaryAffixExcelConfigData].self,
                from: dataStack[.artifactSubProp]!
            )
            self.weaponDB = try decoder.decode(
                [WeaponExcelConfigData].self,
                from: dataStack[.weapon]!
            )
            self.namecardDB = try decoder.decode(
                [MaterialExcelConfigData].self,
                from: dataStack[.namecard]!
            ).filter(\.isValid)
            self.fightPropDB = try decoder.decode(
                [ManualTextMapConfigData].self,
                from: dataStack[.fightProp]!
            ).filter(\.isValid)
            self.skillDepotDB = try decoder.decode(
                [AvatarSkillDepotExcelConfigData].self,
                from: dataStack[.skillDepot]!
            )
            self.costumeDB = try decoder.decode(
                [AvatarCostumeExcelConfigData].self,
                from: dataStack[.costume]!
            )
            if withLang {
                try await updateLanguageMap()
            }
        }

        // MARK: Internal

        let avatarDB: [AvatarExcelConfigData]
        let skillDB: [AvatarSkillExcelConfigData]
        let constellationDB: [AvatarTalentExcelConfigData]
        let artifactDB: [ReliquaryExcelConfigData]
        let artifactSetDB: [EquipAffixExcelConfigData]
        let artifactMainPropDB: [ReliquaryMainPropExcelConfigData]
        let artifactSubPropDB: [ReliquaryAffixExcelConfigData]
        let weaponDB: [WeaponExcelConfigData]
        let namecardDB: [MaterialExcelConfigData]
        let fightPropDB: [ManualTextMapConfigData]
        let skillDepotDB: [AvatarSkillDepotExcelConfigData]
        let costumeDB: [AvatarCostumeExcelConfigData]
        var langTable: [String: [String: String]] = [:]
    }
}

// MARK: - Localization Handlers.

extension DimModels4GI.DimDB4GI {
    private var allNameTextMapHashes: Set<String> {
        let collected: [[Int]] = [
            avatarDB.map(\.nameTextMapHash),
            skillDB.map(\.nameTextMapHash),
            constellationDB.map(\.nameTextMapHash),
            artifactDB.map(\.nameTextMapHash),
            artifactSetDB.map(\.nameTextMapHash),
            weaponDB.map(\.nameTextMapHash),
            namecardDB.map(\.nameTextMapHash),
            fightPropDB.map(\.nameTextMapHash),
            costumeDB.map(\.nameTextMapHash),
        ]
        return Set<String>(collected.reduce([], +).map(\.description))
    }

    mutating func updateLanguageMap() async throws {
        langTable = try await EnkaDBGenerator.SupportedGame
            .genshinImpact.fetchRawLangData(neededHashIDs: allNameTextMapHashes)
        let protagonistTable = getProtagonistTranslations()
        protagonistTable.forEach { protagonist in
            for langTag in langTable.keys {
                let hashTxt = protagonist.nameHash.description
                langTable[langTag, default: [:]][hashTxt] = protagonist.dict[langTag]
            }
        }
    }

    private func getProtagonistTranslations() -> [EnkaDBGenerator.Protagonist.DataPair] {
        let results: [EnkaDBGenerator.Protagonist.DataPair] = avatarDB.compactMap { currentCharacter in
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
        EnkaDBGenerator.SupportedGame.genshinImpact.extraLocMap.forEach { langKey, valTable in
            valTable.forEach { hash, valText in
                enkaLangMap[langKey, default: [:]][hash] = valText
            }
        }
        return enkaLangMap
    }
}
