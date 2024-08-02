// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

// MARK: - DimModels4GI

enum DimModels4GI: String, CaseIterable {
    case avatar = "AvatarExcelConfigData"
    case skill = "AvatarSkillExcelConfigData"
    case constellation = "AvatarTalentExcelConfigData"
    case artifact = "ReliquaryExcelConfigData"
    case artifactSet = "EquipAffixExcelConfigData"
    case artifactMainProp = "ReliquaryMainPropExcelConfigData"
    case artifactSubProp = "ReliquaryAffixExcelConfigData"
    case weapon = "WeaponExcelConfigData"
    case namecard = "MaterialExcelConfigData"
    case fightProp = "ManualTextMapConfigData"
    case skillDepot = "AvatarSkillDepotExcelConfigData"
    case costume = "AvatarCostumeExcelConfigData"
    case profilePicture = "ProfilePictureExcelConfigData"
}

// MARK: DimModelsEnumProtocol

extension DimModels4GI: DimModelsEnumProtocol {
    static let baseURLHeader = "https://gitlab.com/Dimbreath/AnimeGameData/-/raw/master/"
    static var folderName: String { "ExcelBinOutput/" }
    var fileNameStem: String { rawValue }
}

// MARK: DimModels4GI.AvatarExcelConfigData

extension DimModels4GI {
    struct AvatarExcelConfigData: Hashable, Codable, IntegerIdentifiableWithLocHash {
        let id: Int
        let nameTextMapHash: Int
        let iconName: String
        let sideIconName: String
        let qualityType: String
        let skillDepotId: Int
        let candSkillDepotIds: [Int]
        let weaponType: String

        var isValid: Bool {
            guard skillDepotId != 101 else { return false }
            guard !iconName.hasSuffix("_Kate") else { return false }
            guard id.description.prefix(2) != "11" else { return false }
            return true
        }
    }
}

// MARK: DimModels4GI.AvatarSkillExcelConfigData

extension DimModels4GI {
    struct AvatarSkillExcelConfigData: Hashable, Codable, Identifiable {
        let id: Int
        let nameTextMapHash: Int
        let skillIcon: String
        let forceCanDoSkill: Bool?
        let costElemType: String?
        let proudSkillGroupId: Int?

        var isValid: Bool { !skillIcon.isEmpty }
    }
}

// MARK: DimModels4GI.AvatarTalentExcelConfigData

extension DimModels4GI {
    /// Constellations
    struct AvatarTalentExcelConfigData: Hashable, Codable, Identifiable {
        let icon: String
        let nameTextMapHash: Int
        let talentId: Int

        var id: Int { talentId } // Identifiable
    }
}

// MARK: DimModels4GI.ReliquaryExcelConfigData

extension DimModels4GI {
    /// Artifacts
    struct ReliquaryExcelConfigData: Hashable, Codable, Identifiable {
        let id: Int
        let appendPropDepotId: Int
        let equipType: String
        let icon: String
        let itemType: String
        let mainPropDepotId: Int
        let nameTextMapHash: Int
        let rankLevel: Int
    }
}

// MARK: DimModels4GI.EquipAffixExcelConfigData

extension DimModels4GI {
    /// Artifact Set Data
    struct EquipAffixExcelConfigData: Hashable, Codable, Identifiable {
        let affixId: Int
        let nameTextMapHash: Int
        let openConfig: String

        var isValid: Bool {
            // The first 3 chars are spelt correctly.
            openConfig.hasPrefix("Rel")
        }

        var id: Int { affixId } // Identifiable

        var setId: Int {
            Int((Double(affixId) / 10).truncatingRemainder(dividingBy: 1))
        }
    }
}

// MARK: DimModels4GI.ReliquaryMainPropExcelConfigData & ReliquaryAffixExcelConfigData

extension DimModels4GI {
    typealias ReliquaryAffixExcelConfigData = ReliquaryMainPropExcelConfigData

    struct ReliquaryMainPropExcelConfigData: Hashable, Codable, Identifiable {
        // MARK: Lifecycle

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(
                keyedBy: CodingKeys.self
            )
            self.id = try container.decode(Int.self, forKey: .id)
            self.propType = try container.decode(String.self, forKey: .propType)
            self.propValue = (try? container.decodeIfPresent(Double.self, forKey: .propValue)) ?? 0
        }

        // MARK: Internal

        let id: Int
        let propType: String
        let propValue: Double

        var propDigit: String {
            isPercentageType ? "PERCENT" : "DIGIT"
        }

        var propValueRounded: Double {
            (isPercentageType ? (propValue * 100) : propValue).rounded()
        }

        var isPercentageType: Bool {
            ["HURT", "CRITICAL", "EFFICIENCY", "PERCENT", "ADD"].contains(
                propType.split(separator: "_").last
            )
        }
    }
}

// MARK: DimModels4GI.WeaponExcelConfigData

extension DimModels4GI {
    struct WeaponExcelConfigData: Hashable, Codable, Identifiable {
        let id: Int
        let awakenIcon: String
        let icon: String
        let nameTextMapHash: Int
        let rankLevel: Int
    }
}

// MARK: DimModels4GI.MaterialExcelConfigData

extension DimModels4GI {
    /// This struct is only for extrcting NameCards.
    struct MaterialExcelConfigData: Hashable, Codable, Identifiable {
        // MARK: Lifecycle

        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.icon = try container.decode(String.self, forKey: .icon)
            self.materialType = try container.decodeIfPresent(String.self, forKey: .materialType)
            self.nameTextMapHash = try container.decode(Int.self, forKey: .nameTextMapHash)
            self.rankLevel = (try container.decodeIfPresent(Int.self, forKey: .rankLevel)) ?? 4
        }

        // MARK: Internal

        let id: Int
        let icon: String
        let materialType: String?
        let nameTextMapHash: Int
        let rankLevel: Int // All NameCards are ranked at level 4.

        var isValid: Bool {
            materialType == "MATERIAL_NAMECARD"
        }
    }
}

// MARK: DimModels4GI.ManualTextMapConfigData

extension DimModels4GI {
    /// This struct is only for extrcting FightProps.
    struct ManualTextMapConfigData: Hashable, Codable, Identifiable {
        let textMapId: String
        let textMapContentTextMapHash: Int

        var isValid: Bool {
            textMapId.hasPrefix("FIGHT_PROP")
        }

        var nameTextMapHash: Int {
            textMapContentTextMapHash
        }

        var id: String {
            textMapId
        }
    }
}

// MARK: DimModels4GI.AvatarSkillDepotExcelConfigData

extension DimModels4GI {
    struct AvatarSkillDepotExcelConfigData: Hashable, Codable, Identifiable {
        struct InherentProudSkillOpen: Hashable, Codable {
            let proudSkillGroupId: Int?
            let needAvatarPromoteLevel: Int?
        }

        let id: Int
        let energySkill: Int?
        let skills: [Int]
        let subSkills: [Int]
        let extraAbilities: [String]
        let talents: [Int]
        let talentStarName: String
        let inherentProudSkillOpens: [InherentProudSkillOpen]
        let skillDepotAbilityGroup: String
        let leaderTalent: Int?
        let attackModeSkill: Int?
    }
}

// MARK: DimModels4GI.AvatarCostumeExcelConfigData

extension DimModels4GI {
    struct AvatarCostumeExcelConfigData: Hashable, Codable, Identifiable {
        let skinId: Int
        let characterId: Int
        let frontIconName: String
        let nameTextMapHash: Int
        let sideIconName: String

        var id: Int { skinId }
        var art: String { frontIconName.replacingOccurrences(of: "AvatarIcon", with: "Costume") }
        var isValid: Bool { !frontIconName.isEmpty }
    }
}

// MARK: DimModels4GI.ProfilePictureExcelConfigData

extension DimModels4GI {
    struct ProfilePictureExcelConfigData: Hashable, Codable, Identifiable {
        let id: Int
        let iconPath: String
    }
}
