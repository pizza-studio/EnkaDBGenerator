// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - DimModels4GI.DimDB4GI

extension DimModels4GI {
    struct DimDB4GI {
        // MARK: Lifecycle

        init(withLang: Bool = true, oneByOne: Bool = false) async throws {
            let dataStack: [DimModels4GI: Data] = try await getDataStack(oneByOne: oneByOne)
            let decoder = JSONDecoder()
            func decode<T: Decodable>(_ type: T.Type, for tag: DimModels4GI) throws -> T {
                do {
                    return try decoder.decode(type, from: dataStack[tag]!)
                } catch let decodingError as DecodingError {
                    print("// Decoding failed for: \(tag.jsonURL.absoluteString)")
                    throw decodingError
                }
            }

            self.avatarDB = try decode([AvatarExcelConfigData].self, for: .avatar).filter(\.isValid)
            self.skillDB = try decode([AvatarSkillExcelConfigData].self, for: .skill).filter(\.isValid)
            self.constellationDB = try decode([AvatarTalentExcelConfigData].self, for: .constellation)
            self.artifactDB = try decode([ReliquaryExcelConfigData].self, for: .artifact)
            self.artifactSetDB = try decode([EquipAffixExcelConfigData].self, for: .artifactSet).filter(\.isValid)
            self.artifactMainPropDB = try decode([ReliquaryMainPropExcelConfigData].self, for: .artifactMainProp)
            self.artifactSubPropDB = try decode([ReliquaryAffixExcelConfigData].self, for: .artifactSubProp)
            self.weaponDB = try decode([WeaponExcelConfigData].self, for: .weapon)
            self.namecardDB = try decode([MaterialExcelConfigData].self, for: .namecard).filter(\.isValid)
            self.fightPropDB = try decode([ManualTextMapConfigData].self, for: .fightProp).filter(\.isValid)
            self.skillDepotDB = try decode([AvatarSkillDepotExcelConfigData].self, for: .skillDepot)
            self.costumeDB = try decode([AvatarCostumeExcelConfigData].self, for: .costume).filter(\.isValid)
            self.profilePictureDB = try decode([ProfilePictureExcelConfigData].self, for: .profilePicture)
            if withLang {
                try await updateLanguageMap(oneByOne: oneByOne)
                bleach()
            }
        }

        // MARK: Internal

        var avatarDB: [AvatarExcelConfigData]
        var skillDB: [AvatarSkillExcelConfigData]
        var constellationDB: [AvatarTalentExcelConfigData]
        var artifactDB: [ReliquaryExcelConfigData]
        var artifactSetDB: [EquipAffixExcelConfigData]
        var artifactMainPropDB: [ReliquaryMainPropExcelConfigData]
        var artifactSubPropDB: [ReliquaryAffixExcelConfigData]
        var weaponDB: [WeaponExcelConfigData]
        var namecardDB: [MaterialExcelConfigData]
        var fightPropDB: [ManualTextMapConfigData]
        var skillDepotDB: [AvatarSkillDepotExcelConfigData]
        var costumeDB: [AvatarCostumeExcelConfigData]
        var profilePictureDB: [ProfilePictureExcelConfigData]
        var langTable: [String: [String: String]] = [:]
    }
}

// MARK: - DimModels4GI.DimDB4GI + DimDBProtocol

extension DimModels4GI.DimDB4GI: DimDBProtocol {
    static let targetGame: EnkaDBGenerator.SupportedGame = .genshinImpact
    var avatarDBIdentifiable: [any IntegerIdentifiable & NameHashable] { avatarDB }

    var allNameTextMapHashes: Set<String> {
        let collected: [[UInt]] = [
            avatarDB.map(\.nameTextMapHash),
            // skillDB.map(\.nameTextMapHash),
            // constellationDB.map(\.nameTextMapHash),
            // artifactDB.map(\.nameTextMapHash),
            artifactSetDB.map(\.nameTextMapHash),
            weaponDB.map(\.nameTextMapHash),
            namecardDB.map(\.nameTextMapHash),
            // fightPropDB.map(\.nameTextMapHash),
            // costumeDB.map(\.nameTextMapHash),
        ]
        return Set<String>(collected.reduce([], +).map(\.description))
    }

    /// This API is designed for bleaching dev-test contents left in the stable game versions.
    mutating func bleach() {
        guard !langTable.isEmpty else { return }
        let forbiddenHashes = langTable.findForbiddenNameTextMapHashes()
        avatarDB = avatarDB.bleached(against: forbiddenHashes)
        skillDB = skillDB.bleached(against: forbiddenHashes)
        constellationDB = constellationDB.bleached(against: forbiddenHashes)
        artifactDB = artifactDB.bleached(against: forbiddenHashes)
        artifactSetDB = artifactSetDB.bleached(against: forbiddenHashes)
        weaponDB = weaponDB.bleached(against: forbiddenHashes)
        namecardDB = namecardDB.bleached(against: forbiddenHashes)
        fightPropDB = fightPropDB.bleached(against: forbiddenHashes)
        costumeDB = costumeDB.bleached(against: forbiddenHashes)
        forbiddenHashes.forEach { badHash in
            for langTag in langTable.keys {
                langTable[langTag]?.removeValue(forKey: badHash)
            }
        }
    }
}
