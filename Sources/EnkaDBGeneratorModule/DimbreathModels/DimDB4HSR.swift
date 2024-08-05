// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

// MARK: - DimModels4HSR.DimDB4HSR

extension DimModels4HSR {
    struct DimDB4HSR {
        // MARK: Lifecycle

        init(withLang: Bool = true, oneByOne: Bool = false) async throws {
            let dataStack: [DimModels4HSR: Data] = try await getDataStack(oneByOne: oneByOne)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromPascalCase // Vital Important。
            self.avatarDB = try decoder.decode(
                [AvatarConfig].self,
                from: dataStack[.avatar]!
            )
            self.metaAvatarPromotionDB = try decoder.decode(
                [AvatarPromotionConfig].self,
                from: dataStack[.metaAvatarPromotion]!
            )
            self.metaEquipPromotionDB = try decoder.decode(
                [EquipmentPromotionConfig].self,
                from: dataStack[.metaEquipPromotion]!
            )
            self.metaEqupSkillDB = try decoder.decode(
                [EquipmentSkillConfig].self,
                from: dataStack[.metaEqupSkill]!
            )
            self.metaRelicMainAffixDB = try decoder.decode(
                [RelicMainAffixConfig].self,
                from: dataStack[.metaRelicMainAffix]!
            )
            self.metaRelicSubAffixDB = try decoder.decode(
                [RelicSubAffixConfig].self,
                from: dataStack[.metaRelicSubAffix]!
            )
            self.metaRelicSetSkillDB = try decoder.decode(
                [RelicSetSkillConfig].self,
                from: dataStack[.metaRelicSetSkill]!
            )
            self.avatarRankDB = try decoder.decode(
                [AvatarRankConfig].self,
                from: dataStack[.avatarRank]!
            )
            self.relicDB = try decoder.decode(
                [RelicConfig].self,
                from: dataStack[.relic]!
            )
            self.relicDataInfoDB = try decoder.decode(
                [RelicDataInfo].self,
                from: dataStack[.relicDataInfo]!
            )
            self.skillTreeDB = try decoder.decode(
                [AvatarSkillTreeConfig].self,
                from: dataStack[.skillTree]!
            )
            skillTreeDB.hookVertices() // Important!!!!
            self.equipmentDB = try decoder.decode(
                [EquipmentConfig].self,
                from: dataStack[.equipment]!
            )
            // Profile Pictures.
            let pfpDB1 = try decoder.decode(
                [PlayerIcon].self,
                from: dataStack[.profilePicture1]!
            )
            let pfpDB2 = try decoder.decode(
                [PlayerIcon].self,
                from: dataStack[.profilePicture2]!
            )
            self.profilePictureDB = pfpDB1 + pfpDB2
            // Language Table.
            if withLang {
                try await updateLanguageMap(oneByOne: oneByOne)
            }
        }

        // MARK: Internal

        let avatarDB: [AvatarConfig]
        let metaAvatarPromotionDB: [AvatarPromotionConfig]
        let metaEquipPromotionDB: [EquipmentPromotionConfig]
        let metaEqupSkillDB: [EquipmentSkillConfig]
        let metaRelicMainAffixDB: [RelicMainAffixConfig]
        let metaRelicSubAffixDB: [RelicSubAffixConfig]
        let metaRelicSetSkillDB: [RelicSetSkillConfig]
        let avatarRankDB: [AvatarRankConfig]
        let relicDB: [RelicConfig]
        let relicDataInfoDB: [RelicDataInfo]
        let skillTreeDB: [AvatarSkillTreeConfig]
        let equipmentDB: [EquipmentConfig]
        let profilePictureDB: [PlayerIcon]
        var langTable: [String: [String: String]] = [:]
    }
}

// MARK: - DimModels4HSR.DimDB4HSR + DimDBProtocol

extension DimModels4HSR.DimDB4HSR: DimDBProtocol {
    static let targetGame: EnkaDBGenerator.SupportedGame = .starRail
    var avatarDBIdentifiable: [any IntegerIdentifiableWithLocHash] { avatarDB }

    var allNameTextMapHashes: Set<String> {
        let collected: [[Int]] = [
            avatarDB.map(\.nameTextMapHash),
            skillTreeDB.map(\.nameTextMapHash),
            equipmentDB.map(\.nameTextMapHash),
            metaEqupSkillDB.map(\.nameTextMapHash),
        ]
        return Set<String>(collected.reduce([], +).map(\.description))
    }
}
