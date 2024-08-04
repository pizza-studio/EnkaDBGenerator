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
            ).filter(\.isValid)
            self.profilePictureDB = try decoder.decode(
                [ProfilePictureExcelConfigData].self,
                from: dataStack[.profilePicture]!
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
        let profilePictureDB: [ProfilePictureExcelConfigData]
        var langTable: [String: [String: String]] = [:]
    }
}

// MARK: - DimModels4GI.DimDB4GI + DimDBProtocol

extension DimModels4GI.DimDB4GI: DimDBProtocol {
    static let targetGame: EnkaDBGenerator.SupportedGame = .genshinImpact
    var avatarDBIdentifiable: [any IntegerIdentifiableWithLocHash] { avatarDB }

    var allNameTextMapHashes: Set<String> {
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
}