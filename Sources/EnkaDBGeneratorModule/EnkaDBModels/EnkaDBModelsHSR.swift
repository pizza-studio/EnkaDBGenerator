// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

// MARK: - EnkaDBModelsHSR

enum EnkaDBModelsHSR {}

// MARK: - Artifacts (Relics)

extension EnkaDBModelsHSR {
    typealias ArtifactsDict = [String: Artifact]

    struct Artifact: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case rarity = "Rarity"
            case type = "Type"
            case mainAffixGroup = "MainAffixGroup"
            case subAffixGroup = "SubAffixGroup"
            case icon = "Icon"
            case setID = "SetID"
        }

        /// WARNING: It looks insane but HSR internal database messed up the raw values of "object' and "neck".
        var type: String
        var rarity: Int
        var mainAffixGroup: Int
        var subAffixGroup: Int
        var icon: String
        var setID: Int
    }
}

// MARK: - Characters

extension EnkaDBModelsHSR {
    typealias CharacterDict = [String: Character]

    struct Character: Codable, Hashable {
        struct AvatarFullName: Codable, Hashable {
            enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }

            var hash: Int
        }

        struct AvatarName: Codable, Hashable {
            enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }

            var hash: Int
        }

        enum CodingKeys: String, CodingKey {
            case avatarName = "AvatarName"
            case avatarFullName = "AvatarFullName"
            case rarity = "Rarity"
            case element = "Element"
            case avatarBaseType = "AvatarBaseType"
            case avatarSideIconPath = "AvatarSideIconPath"
            case actionAvatarHeadIconPath = "ActionAvatarHeadIconPath"
            case avatarCutinFrontImgPath = "AvatarCutinFrontImgPath"
            case rankIDList = "RankIDList"
            case skillList = "SkillList"
        }

        var avatarName: AvatarName
        var avatarFullName: AvatarFullName
        var rarity: Int
        var element: String
        var avatarBaseType: String
        var avatarSideIconPath: String
        var actionAvatarHeadIconPath: String
        var avatarCutinFrontImgPath: String
        var rankIDList: [Int]
        var skillList: [Int]
    }
}

// MARK: EnkaDBModelsHSR.Meta

extension EnkaDBModelsHSR {
    struct Meta: Codable, Hashable {
        var avatar: RawAvatarMetaDict
        var equipment: RawEquipmentMetaDict
        var equipmentSkill: RawEquipSkillMetaDict
        var relic: RawRelicDB
        var tree: RawTreeMetaDict
    }
}

// MARK: - EnkaDBModelsHSR.Meta.NestedPropValueMap

extension EnkaDBModelsHSR.Meta {
    typealias NestedPropValueMap = [String: [String: [String: [String: Double]]]]
}

// MARK: - Meta.AvatarMeta

extension EnkaDBModelsHSR.Meta {
    typealias RawAvatarMetaDict = [String: [String: AvatarMeta]]

    struct AvatarMeta: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case hpBase = "HPBase"
            case hpAdd = "HPAdd"
            case attackBase = "AttackBase"
            case attackAdd = "AttackAdd"
            case defenceBase = "DefenceBase"
            case defenceAdd = "DefenceAdd"
            case speedBase = "SpeedBase"
            case criticalChance = "CriticalChance"
            case criticalDamage = "CriticalDamage"
            case baseAggro = "BaseAggro"
        }

        var hpBase: Double
        var hpAdd: Double
        var attackBase: Double
        var attackAdd: Double
        var defenceBase: Double
        var defenceAdd: Double
        var speedBase: Double
        var criticalChance: Double
        var criticalDamage: Double
        var baseAggro: Double
    }
}

// MARK: - Meta.EquipmentMeta

extension EnkaDBModelsHSR.Meta {
    typealias RawEquipmentMetaDict = [String: [String: EquipmentMeta]]

    struct EquipmentMeta: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case baseHP = "BaseHP"
            case hpAdd = "HPAdd"
            case baseAttack = "BaseAttack"
            case attackAdd = "AttackAdd"
            case baseDefence = "BaseDefence"
            case defenceAdd = "DefenceAdd"
        }

        var baseHP: Double
        var hpAdd: Double
        var baseAttack: Double
        var attackAdd: Double
        var baseDefence: Double
        var defenceAdd: Double
    }
}

// MARK: - EnkaDBModelsHSR.Meta.RawEquipSkillMetaDict

extension EnkaDBModelsHSR.Meta {
    typealias RawEquipSkillMetaDict = NestedPropValueMap
}

// MARK: - EnkaDBModelsHSR.Meta.RawRelicDB

// Relic = Artifact

extension EnkaDBModelsHSR.Meta {
    struct RawRelicDB: Codable, Hashable {
        struct MainAffix: Codable, Hashable {
            enum CodingKeys: String, CodingKey {
                case property = "Property"
                case baseValue = "BaseValue"
                case levelAdd = "LevelAdd"
            }

            var property: String
            var baseValue: Double
            var levelAdd: Double
        }

        struct SubAffix: Codable, Hashable {
            enum CodingKeys: String, CodingKey {
                case property = "Property"
                case baseValue = "BaseValue"
                case stepValue = "StepValue"
            }

            var property: String
            var baseValue: Double
            var stepValue: Double
        }

        typealias MainAffixTable = [String: [String: MainAffix]]
        typealias SubAffixTable = [String: [String: SubAffix]]
        typealias RawSetSkillMetaDict = EnkaDBModelsHSR.Meta.NestedPropValueMap

        var mainAffix: MainAffixTable
        var subAffix: SubAffixTable
        var setSkill: RawSetSkillMetaDict
    }
}

// MARK: - EnkaDBModelsHSR.Meta.RawTreeMetaDict

extension EnkaDBModelsHSR.Meta {
    typealias RawTreeMetaDict = NestedPropValueMap
}

// MARK: - Profile Avatar

extension EnkaDBModelsHSR {
    typealias ProfileAvatarDict = [String: ProfileAvatar]

    struct ProfileAvatar: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case icon = "Icon"
        }

        var icon: String
    }
}

// MARK: - Skill Ranks

extension EnkaDBModelsHSR {
    typealias SkillRanksDict = [String: SkillRank]

    struct SkillRank: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case iconPath = "IconPath"
            case skillAddLevelList = "SkillAddLevelList"
        }

        var iconPath: String
        var skillAddLevelList: [String: Int]
    }
}

// MARK: - Skills

extension EnkaDBModelsHSR {
    typealias SkillsDict = [String: Skill]

    struct Skill: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case iconPath = "IconPath"
            case pointType = "PointType"
        }

        var iconPath: String
        var pointType: Int
    }
}

// MARK: - SkillTree

extension EnkaDBModelsHSR {
    typealias SkillTreesDict = [String: SkillTree]

    typealias SkillTree = [String: [SkillInTree]]

    enum SkillInTree: Codable, Hashable {
        case baseSkill(String)
        case extendedSkills([String])

        // MARK: Lifecycle

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([String].self) {
                self = .extendedSkills(x)
                return
            }
            if let x = try? container.decode(String.self) {
                self = .baseSkill(x)
                return
            }
            throw DecodingError.typeMismatch(
                SkillInTree.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SkillInTree")
            )
        }

        // MARK: Internal

        var firstSkillNodeID: String? {
            switch self {
            case let .baseSkill(string): return string
            case let .extendedSkills(array): return array.first
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .baseSkill(x):
                try container.encode(x)
            case let .extendedSkills(x):
                try container.encode(x)
            }
        }

        mutating func appendExtendedSkill(_ newSkillNodeID: String) {
            guard case var .extendedSkills(array) = self else { return }
            array.append(newSkillNodeID)
            self = .extendedSkills(array)
        }
    }
}

// MARK: - Weapons

extension EnkaDBModelsHSR {
    typealias WeaponsDict = [String: Weapon]

    struct Weapon: Codable, Hashable {
        struct EquipmentName: Codable, Hashable {
            enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }

            var hash: Int
        }

        enum CodingKeys: String, CodingKey {
            case rarity = "Rarity"
            case avatarBaseType = "AvatarBaseType"
            case equipmentName = "EquipmentName"
            case imagePath = "ImagePath"
        }

        var rarity: Int
        var avatarBaseType: String
        var equipmentName: EquipmentName
        var imagePath: String
    }
}
