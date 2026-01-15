// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - DimModels4HSR.DimDB4HSR

extension DimModels4HSR {
    struct DimDB4HSR {
        // MARK: Lifecycle

        init(withLang: Bool = true, oneByOne: Bool = false) async throws {
            let dataStack: [DimModels4HSR: Data] = try await getDataStack(
                oneByOne: oneByOne, isCollab: false
            )
            let dataStack4Collab: [DimModels4HSR: Data] = try await getDataStack(
                oneByOne: oneByOne, isCollab: true
            )
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromPascalCase // Vital Important。
            func decode<T: Decodable>(
                _ type: T.Type,
                for tag: DimModels4HSR,
                isCollab: Bool = false
            ) throws
                -> T {
                let stack = isCollab ? dataStack4Collab : dataStack
                let url = isCollab ? (tag.jsonURL4Collab ?? tag.jsonURL) : tag.jsonURL
                do {
                    return try decoder.decode(type, from: stack[tag]!)
                } catch let decodingError as DecodingError {
                    print("// Decoding failed for: \(url.absoluteString)")
                    throw decodingError
                }
            }

            self.avatarDB = try decode(
                [AvatarConfig].self,
                for: .avatar
            ).filter(\.isValid) + decode(
                [AvatarConfig].self,
                for: .avatar,
                isCollab: true
            ).filter(\.isValid)
            avatarDB.sort { $0.avatarID < $1.avatarID }
            self.metaAvatarPromotionDB = try decode(
                [AvatarPromotionConfig].self,
                for: .metaAvatarPromotion
            ).filter(\.isValid) + decode(
                [AvatarPromotionConfig].self,
                for: .metaAvatarPromotion,
                isCollab: true
            ).filter(\.isValid)
            metaAvatarPromotionDB.sort { $0.avatarID < $1.avatarID }
            self.equipmentDB = try decode(
                [EquipmentConfig].self,
                for: .equipment
            ).filter(\.isValid)
            let allEquipIDs = equipmentDB.map(\.equipmentID)
            self.metaEquipPromotionDB = try decode(
                [EquipmentPromotionConfig].self,
                for: .metaEquipPromotion
            ).filter { allEquipIDs.contains($0.equipmentID) }
            self.metaEqupSkillDB = try decode(
                [EquipmentSkillConfig].self,
                for: .metaEqupSkill
            ).filter(\.isValid)
            self.metaRelicMainAffixDB = try decode(
                [RelicMainAffixConfig].self,
                for: .metaRelicMainAffix
            )
            self.metaRelicSubAffixDB = try decode(
                [RelicSubAffixConfig].self,
                for: .metaRelicSubAffix
            )
            self.metaRelicSetSkillDB = try decode(
                [RelicSetSkillConfig].self,
                for: .metaRelicSetSkill
            )
            self.avatarRankDB = try decode(
                [AvatarRankConfig].self,
                for: .avatarRank
            ).filter(\.isValid) + decode(
                [AvatarRankConfig].self,
                for: .avatarRank,
                isCollab: true
            ).filter(\.isValid)
            avatarRankDB.sort { $0.rankID < $1.rankID }
            self.relicDB = try decode(
                [RelicConfig].self,
                for: .relic
            )
            self.relicDataInfoDB = try decode(
                [RelicDataInfo].self,
                for: .relicDataInfo
            )
            self.relicSetDB = try decode(
                [RelicSetConfig].self,
                for: .relicSet
            ).filter(\.isValid)
            self.skillTreeDB = try decode(
                [AvatarSkillTreeConfig].self,
                for: .skillTree
            ).filter(\.isValid) + decode(
                [AvatarSkillTreeConfig].self,
                for: .skillTree,
                isCollab: true
            ).filter(\.isValid)
            skillTreeDB.sort { $0.pointID < $1.pointID }
            skillTreeDB.hookVertices() // Important!!!!
            // Profile Pictures.
            let pfpDB1 = try decode(
                [PlayerIcon].self,
                for: .profilePicture1
            )
            let pfpDB2 = try decode(
                [PlayerIcon].self,
                for: .profilePicture2
            )
            let pfpDBCollab = try decode(
                [PlayerIcon].self,
                for: .profilePicture1,
                isCollab: true
            )
            self.profilePictureDB = pfpDB1 + pfpDB2 + pfpDBCollab
            // Language Table.
            if withLang {
                try await updateLanguageMap(oneByOne: oneByOne)
                bleach()
            }
        }

        // MARK: Internal

        var avatarDB: [AvatarConfig]
        var metaAvatarPromotionDB: [AvatarPromotionConfig]
        var metaEquipPromotionDB: [EquipmentPromotionConfig]
        var metaEqupSkillDB: [EquipmentSkillConfig]
        var metaRelicMainAffixDB: [RelicMainAffixConfig]
        var metaRelicSubAffixDB: [RelicSubAffixConfig]
        var metaRelicSetSkillDB: [RelicSetSkillConfig]
        var avatarRankDB: [AvatarRankConfig]
        var relicDB: [RelicConfig]
        var relicDataInfoDB: [RelicDataInfo]
        var relicSetDB: [RelicSetConfig]
        var skillTreeDB: [AvatarSkillTreeConfig]
        var equipmentDB: [EquipmentConfig]
        var profilePictureDB: [PlayerIcon]
        var langTable: [String: [String: String]] = [:]
    }
}

// MARK: - DimModels4HSR.DimDB4HSR + DimDBProtocol

extension DimModels4HSR.DimDB4HSR: DimDBProtocol {
    static let targetGame: EnkaDBGenerator.SupportedGame = .starRail
    var avatarDBIdentifiable: [any IntegerIdentifiable & NameHashable] { avatarDB }

    var allNameTextMapHashes: Set<String> {
        let collected: [[UInt]] = [
            avatarDB.map(\.nameTextMapHash),
            // skillTreeDB.map(\.nameTextMapHash),
            equipmentDB.map(\.nameTextMapHash),
            relicSetDB.map(\.nameTextMapHash),
            // metaEqupSkillDB.map(\.nameTextMapHash),
        ]
        return Set<String>(collected.reduce([], +).map(\.description))
    }

    /// This API is designed for bleaching dev-test contents left in the stable game versions.
    mutating func bleach() {
        guard !langTable.isEmpty else { return }
        let forbiddenHashes = langTable.findForbiddenNameTextMapHashes()
        avatarDB = avatarDB.bleached(against: forbiddenHashes)
        skillTreeDB = skillTreeDB.bleached(against: forbiddenHashes)
        equipmentDB = equipmentDB.bleached(against: forbiddenHashes)
        metaEqupSkillDB = metaEqupSkillDB.bleached(against: forbiddenHashes)
        forbiddenHashes.forEach { badHash in
            for langTag in langTable.keys {
                langTable[langTag]?.removeValue(forKey: badHash)
            }
        }
    }
}
