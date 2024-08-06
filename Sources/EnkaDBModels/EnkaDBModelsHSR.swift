// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - EnkaDBModelsHSR

public enum EnkaDBModelsHSR {}

// MARK: - Artifacts (Relics)

extension EnkaDBModelsHSR {
    public typealias ArtifactsDict = [String: Artifact]

    public struct Artifact: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            type: String,
            rarity: Int,
            mainAffixGroup: Int,
            subAffixGroup: Int,
            icon: String,
            setID: Int
        ) {
            self.type = type
            self.rarity = rarity
            self.mainAffixGroup = mainAffixGroup
            self.subAffixGroup = subAffixGroup
            self.icon = icon
            self.setID = setID
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case rarity = "Rarity"
            case type = "Type"
            case mainAffixGroup = "MainAffixGroup"
            case subAffixGroup = "SubAffixGroup"
            case icon = "Icon"
            case setID = "SetID"
        }

        /// WARNING: It looks insane but HSR internal database messed up the raw values of "object' and "neck".
        public var type: String
        public var rarity: Int
        public var mainAffixGroup: Int
        public var subAffixGroup: Int
        public var icon: String
        public var setID: Int
    }
}

// MARK: - Characters

extension EnkaDBModelsHSR {
    public typealias CharacterDict = [String: Character]

    public struct Character: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            avatarName: AvatarName,
            avatarFullName: AvatarFullName,
            rarity: Int,
            element: String,
            avatarBaseType: String,
            avatarSideIconPath: String,
            actionAvatarHeadIconPath: String,
            avatarCutinFrontImgPath: String,
            rankIDList: [Int],
            skillList: [Int]
        ) {
            self.avatarName = avatarName
            self.avatarFullName = avatarFullName
            self.rarity = rarity
            self.element = element
            self.avatarBaseType = avatarBaseType
            self.avatarSideIconPath = avatarSideIconPath
            self.actionAvatarHeadIconPath = actionAvatarHeadIconPath
            self.avatarCutinFrontImgPath = avatarCutinFrontImgPath
            self.rankIDList = rankIDList
            self.skillList = skillList
        }

        // MARK: Public

        public struct AvatarFullName: Codable, Hashable {
            // MARK: Lifecycle

            public init(hash: Int) {
                self.hash = hash
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }

            public var hash: Int
        }

        public struct AvatarName: Codable, Hashable {
            // MARK: Lifecycle

            public init(hash: Int) {
                self.hash = hash
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }

            public var hash: Int
        }

        public enum CodingKeys: String, CodingKey {
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

        public var avatarName: AvatarName
        public var avatarFullName: AvatarFullName
        public var rarity: Int
        public var element: String
        public var avatarBaseType: String
        public var avatarSideIconPath: String
        public var actionAvatarHeadIconPath: String
        public var avatarCutinFrontImgPath: String
        public var rankIDList: [Int]
        public var skillList: [Int]
    }
}

// MARK: EnkaDBModelsHSR.Meta

extension EnkaDBModelsHSR {
    public struct Meta: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            avatar: RawAvatarMetaDict,
            equipment: RawEquipmentMetaDict,
            equipmentSkill: RawEquipSkillMetaDict,
            relic: RawRelicDB,
            tree: RawTreeMetaDict
        ) {
            self.avatar = avatar
            self.equipment = equipment
            self.equipmentSkill = equipmentSkill
            self.relic = relic
            self.tree = tree
        }

        // MARK: Public

        public var avatar: RawAvatarMetaDict
        public var equipment: RawEquipmentMetaDict
        public var equipmentSkill: RawEquipSkillMetaDict
        public var relic: RawRelicDB
        public var tree: RawTreeMetaDict
    }
}

// MARK: - EnkaDBModelsHSR.Meta.NestedPropValueMap

extension EnkaDBModelsHSR.Meta {
    public typealias NestedPropValueMap = [String: [String: [String: [String: Double]]]]
}

// MARK: - Meta.AvatarMeta

extension EnkaDBModelsHSR.Meta {
    public typealias RawAvatarMetaDict = [String: [String: AvatarMeta]]

    public struct AvatarMeta: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            hpBase: Double,
            hpAdd: Double,
            attackBase: Double,
            attackAdd: Double,
            defenceBase: Double,
            defenceAdd: Double,
            speedBase: Double,
            criticalChance: Double,
            criticalDamage: Double,
            baseAggro: Double
        ) {
            self.hpBase = hpBase
            self.hpAdd = hpAdd
            self.attackBase = attackBase
            self.attackAdd = attackAdd
            self.defenceBase = defenceBase
            self.defenceAdd = defenceAdd
            self.speedBase = speedBase
            self.criticalChance = criticalChance
            self.criticalDamage = criticalDamage
            self.baseAggro = baseAggro
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
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

        public var hpBase: Double
        public var hpAdd: Double
        public var attackBase: Double
        public var attackAdd: Double
        public var defenceBase: Double
        public var defenceAdd: Double
        public var speedBase: Double
        public var criticalChance: Double
        public var criticalDamage: Double
        public var baseAggro: Double
    }
}

// MARK: - Meta.EquipmentMeta

extension EnkaDBModelsHSR.Meta {
    public typealias RawEquipmentMetaDict = [String: [String: EquipmentMeta]]

    public struct EquipmentMeta: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            baseHP: Double,
            hpAdd: Double,
            baseAttack: Double,
            attackAdd: Double,
            baseDefence: Double,
            defenceAdd: Double
        ) {
            self.baseHP = baseHP
            self.hpAdd = hpAdd
            self.baseAttack = baseAttack
            self.attackAdd = attackAdd
            self.baseDefence = baseDefence
            self.defenceAdd = defenceAdd
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case baseHP = "BaseHP"
            case hpAdd = "HPAdd"
            case baseAttack = "BaseAttack"
            case attackAdd = "AttackAdd"
            case baseDefence = "BaseDefence"
            case defenceAdd = "DefenceAdd"
        }

        public var baseHP: Double
        public var hpAdd: Double
        public var baseAttack: Double
        public var attackAdd: Double
        public var baseDefence: Double
        public var defenceAdd: Double
    }
}

// MARK: - EnkaDBModelsHSR.Meta.RawEquipSkillMetaDict

extension EnkaDBModelsHSR.Meta {
    public typealias RawEquipSkillMetaDict = NestedPropValueMap
}

// MARK: - EnkaDBModelsHSR.Meta.RawRelicDB

// Relic = Artifact

extension EnkaDBModelsHSR.Meta {
    public struct RawRelicDB: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            mainAffix: MainAffixTable,
            subAffix: SubAffixTable,
            setSkill: RawSetSkillMetaDict
        ) {
            self.mainAffix = mainAffix
            self.subAffix = subAffix
            self.setSkill = setSkill
        }

        // MARK: Public

        public struct MainAffix: Codable, Hashable {
            // MARK: Lifecycle

            public init(property: String, baseValue: Double, levelAdd: Double) {
                self.property = property
                self.baseValue = baseValue
                self.levelAdd = levelAdd
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case property = "Property"
                case baseValue = "BaseValue"
                case levelAdd = "LevelAdd"
            }

            public var property: String
            public var baseValue: Double
            public var levelAdd: Double
        }

        public struct SubAffix: Codable, Hashable {
            // MARK: Lifecycle

            public init(property: String, baseValue: Double, stepValue: Double) {
                self.property = property
                self.baseValue = baseValue
                self.stepValue = stepValue
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case property = "Property"
                case baseValue = "BaseValue"
                case stepValue = "StepValue"
            }

            public var property: String
            public var baseValue: Double
            public var stepValue: Double
        }

        public typealias MainAffixTable = [String: [String: MainAffix]]
        public typealias SubAffixTable = [String: [String: SubAffix]]
        public typealias RawSetSkillMetaDict = EnkaDBModelsHSR.Meta.NestedPropValueMap

        public var mainAffix: MainAffixTable
        public var subAffix: SubAffixTable
        public var setSkill: RawSetSkillMetaDict
    }
}

// MARK: - EnkaDBModelsHSR.Meta.RawTreeMetaDict

extension EnkaDBModelsHSR.Meta {
    public typealias RawTreeMetaDict = NestedPropValueMap
}

// MARK: - Profile Avatar

extension EnkaDBModelsHSR {
    public typealias ProfileAvatarDict = [String: ProfileAvatar]

    public struct ProfileAvatar: Codable, Hashable {
        // MARK: Lifecycle

        public init(icon: String) {
            self.icon = icon
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case icon = "Icon"
        }

        public var icon: String
    }
}

// MARK: - Skill Ranks

extension EnkaDBModelsHSR {
    public typealias SkillRanksDict = [String: SkillRank]

    public struct SkillRank: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            iconPath: String,
            skillAddLevelList: [String: Int]
        ) {
            self.iconPath = iconPath
            self.skillAddLevelList = skillAddLevelList
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case iconPath = "IconPath"
            case skillAddLevelList = "SkillAddLevelList"
        }

        public var iconPath: String
        public var skillAddLevelList: [String: Int]
    }
}

// MARK: - Skills

extension EnkaDBModelsHSR {
    public typealias SkillsDict = [String: Skill]

    public struct Skill: Codable, Hashable {
        // MARK: Lifecycle

        public init(iconPath: String, pointType: Int) {
            self.iconPath = iconPath
            self.pointType = pointType
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case iconPath = "IconPath"
            case pointType = "PointType"
        }

        public var iconPath: String
        public var pointType: Int
    }
}

// MARK: - SkillTree

extension EnkaDBModelsHSR {
    public typealias SkillTreesDict = [String: SkillTree]

    public typealias SkillTree = [String: [SkillInTree]]

    public enum SkillInTree: Codable, Hashable, Equatable {
        case baseSkill(String)
        case extendedSkills([String])

        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
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
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Wrong type for SkillInTree"
                )
            )
        }

        // MARK: Public

        public var firstSkillNodeID: String? {
            switch self {
            case let .baseSkill(string): return string
            case let .extendedSkills(array): return array.first
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .baseSkill(x):
                try container.encode(x)
            case let .extendedSkills(x):
                try container.encode(x)
            }
        }

        // MARK: Internal

        mutating func appendExtendedSkill(_ newSkillNodeID: String) {
            guard case var .extendedSkills(array) = self else { return }
            array.append(newSkillNodeID)
            self = .extendedSkills(array)
        }
    }
}

// MARK: - Weapons

extension EnkaDBModelsHSR {
    public typealias WeaponsDict = [String: Weapon]

    public struct Weapon: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            rarity: Int,
            avatarBaseType: String,
            equipmentName: EquipmentName,
            imagePath: String
        ) {
            self.rarity = rarity
            self.avatarBaseType = avatarBaseType
            self.equipmentName = equipmentName
            self.imagePath = imagePath
        }

        // MARK: Public

        public struct EquipmentName: Codable, Hashable {
            // MARK: Lifecycle

            public init(hash: Int) {
                self.hash = hash
            }

            // MARK: Public

            public enum CodingKeys: String, CodingKey {
                case hash = "Hash"
            }

            public var hash: Int
        }

        public enum CodingKeys: String, CodingKey {
            case rarity = "Rarity"
            case avatarBaseType = "AvatarBaseType"
            case equipmentName = "EquipmentName"
            case imagePath = "ImagePath"
        }

        public var rarity: Int
        public var avatarBaseType: String
        public var equipmentName: EquipmentName
        public var imagePath: String
    }
}
