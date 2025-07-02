// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - DimModels4HSR

enum DimModels4HSR: String, CaseIterable, Sendable {
    case avatar = "AvatarConfig"
    case metaAvatarPromotion = "AvatarPromotionConfig"
    case metaEquipPromotion = "EquipmentPromotionConfig"
    case metaEqupSkill = "EquipmentSkillConfig"
    case metaRelicMainAffix = "RelicMainAffixConfig"
    case metaRelicSubAffix = "RelicSubAffixConfig"
    case metaRelicSetSkill = "RelicSetSkillConfig"
    case avatarRank = "AvatarRankConfig"
    case relic = "RelicConfig"
    case relicDataInfo = "RelicDataInfo"
    case relicSet = "RelicSetConfig"
    case skillTree = "AvatarSkillTreeConfig" // Used in multiple scenarios.
    case equipment = "EquipmentConfig"
    case profilePicture1 = "AvatarPlayerIcon"
    case profilePicture2 = "PlayerIcon"
}

// MARK: DimModelsEnumProtocol

extension DimModels4HSR: DimModelsEnumProtocol {
    static let baseURLHeader = "https://gitlab.com/Dimbreath/TurnBasedGameData/-/raw/main/"
    static var folderName: String { "ExcelOutput/" }
    var fileNameStem: String { rawValue }
}

// MARK: DimModels4HSR.AvatarConfig

extension DimModels4HSR {
    struct AvatarConfig: Hashable, Decodable, IntegerIdentifiable, NameHashable {
        struct Avatar: Hashable, Decodable {
            let hash: UInt
        }

        let avatarID: Int
        let avatarName: Avatar
        let avatarFullName: Avatar
        let rarity: String
        let damageType: String
        let avatarBaseType: String
        let avatarSideIconPath: String
        let actionAvatarHeadIconPath: String
        let avatarCutinFrontImgPath: String
        let rankIDList: [Int]
        let skillList: [Int]

        var id: Int { avatarID }

        var isValid: Bool {
            switch id {
            case 6000 ..< 8000, 8900...: return false
            default: break
            }
            let wrongRankIDs = rankIDList.filter {
                (700000 ..< 800000).contains($0)
            }
            guard wrongRankIDs.isEmpty else { return false }

            let wrongSkills = skillList.filter {
                (7000000 ..< 8000000).contains($0)
            }
            guard wrongSkills.isEmpty else { return false }
            return true
        }

        var nameTextMapHash: UInt {
            avatarName.hash
        }

        var element: String {
            damageType
        }
    }
}

// MARK: DimModels4HSR.AvatarPromotionConfig

extension DimModels4HSR {
    /// Meta - metaAvatarPromotion
    struct AvatarPromotionConfig: Hashable, Decodable, Identifiable {
        struct ValueWrapper: Hashable, Decodable {
            let value: Double
        }

        struct PromotionCost: Hashable, Decodable {
            let itemID: Int
            let itemNum: Int
        }

        let avatarID: Int
        let promotionCostList: [PromotionCost]
        let maxLevel: Int
        let playerLevelRequire: Int?
        let attackBase: ValueWrapper
        let attackAdd: ValueWrapper
        let defenceBase: ValueWrapper
        let defenceAdd: ValueWrapper
        let hpBase: ValueWrapper
        let hpAdd: ValueWrapper
        let speedBase: ValueWrapper
        let criticalChance: ValueWrapper
        let criticalDamage: ValueWrapper
        let baseAggro: ValueWrapper
        let promotion: Int?
        let worldLevelRequire: Int?

        var promotionGuarded: Int {
            promotion ?? 0
        }

        var id: String {
            "\(avatarID)_\(promotionGuarded)"
        }

        var isValid: Bool {
            switch avatarID {
            case 6000 ..< 8000, 8900...: false
            default: true
            }
        }
    }
}

// MARK: DimModels4HSR.EquipmentPromotionConfig

extension DimModels4HSR {
    /// Meta - metaEquipPromotion
    struct EquipmentPromotionConfig: Hashable, Decodable, Identifiable {
        struct ValueWrapper: Hashable, Decodable {
            let value: Double
        }

        struct PromotionCost: Hashable, Decodable {
            let itemID: Int
            let itemNum: Int
        }

        let equipmentID: Int
        let promotionCostList: [PromotionCost]
        let playerLevelRequire: Int?
        let maxLevel: Int
        let baseHP: ValueWrapper
        let baseHPAdd: ValueWrapper
        let baseAttack: ValueWrapper
        let baseAttackAdd: ValueWrapper
        let baseDefence: ValueWrapper
        let baseDefenceAdd: ValueWrapper
        let promotion: Int?
        let worldLevelRequire: Int?

        var promotionGuarded: Int {
            promotion ?? 0
        }

        var id: String {
            "\(equipmentID)_\(promotionGuarded)"
        }
    }
}

// MARK: DimModels4HSR.EquipmentSkillConfig

extension DimModels4HSR {
    /// Meta - metaEqupSkill
    struct EquipmentSkillConfig: Hashable, Decodable, Identifiable, NameHashable {
        struct ValueWrapper: Hashable, Decodable {
            struct Param: Hashable, Decodable {
                let value: Double
            }

            let propertyType: String
            let value: Param
        }

        struct Skill: Hashable, Decodable {
            let hash: UInt
        }

        let skillID: Int
        let skillName: Skill
        let skillDesc: Skill
        let level: Int
        let abilityName: String
        let paramList: [ValueWrapper.Param]
        let abilityProperty: [ValueWrapper]

        var id: Int { skillID }

        var isValid: Bool {
            switch id {
            case 7000000 ..< 8000000: false
            default: true
            }
        }

        var nameTextMapHash: UInt {
            skillName.hash
        }
    }
}

// MARK: DimModels4HSR.RelicMainAffixConfig

extension DimModels4HSR {
    /// Meta - metaRelicMainAffix
    struct RelicMainAffixConfig: Hashable, Decodable, Identifiable {
        struct Param: Hashable, Decodable {
            let value: Double
        }

        let groupID: Int
        let affixID: Int
        let property: String
        let baseValue: Param
        let levelAdd: Param

        var id: String {
            "\(groupID)_\(affixID)"
        }
    }
}

// MARK: DimModels4HSR.RelicSubAffixConfig

extension DimModels4HSR {
    /// Meta - metaRelicSubAffix
    struct RelicSubAffixConfig: Hashable, Decodable, Identifiable {
        struct Param: Hashable, Decodable {
            let value: Double
        }

        let groupID: Int
        let affixID: Int
        let property: String
        let baseValue: Param
        let stepValue: Param
        let stepNum: Int

        var id: String {
            "\(groupID)_\(affixID)"
        }
    }
}

// MARK: DimModels4HSR.RelicSetConfig

extension DimModels4HSR {
    /// Meta - metaRelicSubAffix
    struct RelicSetConfig: Hashable, Decodable, Identifiable, NameHashable {
        struct SetName: Hashable, Decodable {
            let hash: UInt
        }

        let setID: Int
        let setSkillList: [Int]
        let setIconPath: String
        let setIconFigurePath: String
        let setName: SetName
        let displayItemID: Int
        let release: Bool
        let isPlanarSuit: Bool?

        var nameTextMapHash: UInt {
            setName.hash
        }

        var id: String {
            setID.description
        }

        var isValid: Bool {
            let wrongSkills = setSkillList.filter {
                (7000000 ..< 8000000).contains($0)
            }
            guard wrongSkills.isEmpty else { return false }
            return true
        }
    }
}

// MARK: DimModels4HSR.RelicSetSkillConfig

extension DimModels4HSR {
    /// Meta - metaRelicSetSkill
    struct RelicSetSkillConfig: Hashable, Decodable, Identifiable {
        /// CodingKeys in this struct varies per each HSR update.
        /// Therefore, we decode it as a Dictionary.
        struct PropertyList: Hashable, Decodable {
            // MARK: Lifecycle

            init(from decoder: any Decoder) throws {
                let containerRAW = try decoder.singleValueContainer()
                let theMap = try containerRAW.decode([String: PListValue].self)
                let titleRawValue = theMap.values.compactMap {
                    if case let PListValue.title(neta) = $0 { neta } else { nil }
                }.first
                let valueStorage = theMap.values.compactMap {
                    if case let PListValue.param(neta) = $0 { neta } else { nil }
                }.first

                guard let valueStorage else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: [CodingKeys.valueStorage],
                        debugDescription: "NULL."
                    ))
                }
                guard let titleRawValue else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: [CodingKeys.titleRawValue],
                        debugDescription: "NULL."
                    ))
                }
                self.valueStorage = valueStorage
                self.titleRawValue = titleRawValue
            }

            // MARK: Internal

            struct Param: Hashable, Decodable {
                let value: Double
            }

            enum PListValue: Decodable, Hashable {
                case title(String)
                case param(Param)

                // MARK: Lifecycle

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let x = try? container.decode(Param.self) {
                        self = .param(x)
                        return
                    }
                    if let x = try? container.decode(String.self) {
                        self = .title(x)
                        return
                    }
                    throw DecodingError.typeMismatch(
                        PropertyList.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Wrong type for RelicSetSkillConfig.PropertyList"
                        )
                    )
                }
            }

            enum CodingKeys: String, CodingKey {
                case titleRawValue
                case valueStorage
            }

            let titleRawValue: String
            let valueStorage: Param
        }

        let setID: Int
        let requireNum: Int
        let skillDesc: String
        let propertyList: [PropertyList]
        let abilityName: String
        let abilityParamList: [PropertyList.Param]

        var id: Int { setID }
    }
}

// MARK: DimModels4HSR.AvatarSkillTreeConfig

extension DimModels4HSR {
    /// This struct uses in multiple scenarios.
    /// Class is used in this case.
    class AvatarSkillTreeConfig: Decodable, Identifiable, NameHashable, Hashable {
        struct Material: Hashable, Decodable {
            let itemID: Int
            let itemNum: Int
        }

        struct Param: Hashable, Decodable {
            let value: Double
        }

        enum PointTriggerKey: String, Hashable, Decodable {
            case normal = "PointNormal"
            case bpSkill = "PointBPSkill"
            case ultra = "PointUltra"
            case passive = "PointPassive"
            case maze = "PointMaze"
            case s1 = "PointS1"
            case s2 = "PointS2"
            case s3 = "PointS3"
            case s4 = "PointS4"
            case s5 = "PointS5"
            case s6 = "PointS6"
            case s7 = "PointS7"
            case s8 = "PointS8"
            case s9 = "PointS9"
            case s10 = "PointS10"
            case b1 = "PointB1"
            case b2 = "PointB2"
            case b3 = "PointB3"
            case servant1 = "PointServant1"
            case servant2 = "PointServant2"
        }

        struct StatusAdd: Hashable, Decodable {
            let propertyType: String
            let value: Param
        }

        let pointID: Int
        let level: Int
        let avatarID: Int
        let pointType: Int
        let anchor: String
        let maxLevel: Int
        let defaultUnlock: Bool?
        let prePoint: [Int]
        let statusAddList: [StatusAdd]
        let materialList: [Material]
        let levelUpSkillID: [Int]
        let iconPath: String
        let pointName: String
        let pointDesc: String
        let recommendPriority: Int?
        let abilityName: String
        let pointTriggerKey: PointTriggerKey
        let paramList: [Param]
        let avatarPromotionLimit: Int?
        let avatarLevelLimit: Int?

        weak var previousVertex: AvatarSkillTreeConfig?
        var nextVertices: [AvatarSkillTreeConfig]? = []

        var id: Int { pointID }

        var isValid: Bool {
            switch avatarID {
            case 6000 ..< 8000, 8900...: false
            default: true
            }
        }

        var nameTextMapHash: UInt {
            .init(Swift.abs(pointName.hash))
        }

        var hasMultipleNestedNextVertices: Bool {
            guard let nextVertices = nextVertices else { return false }
            guard nextVertices.count > 1 else { return false }
            for vertex in nextVertices {
                if vertex.nextVertices != nil {
                    return true
                }
            }
            return false
        }

        var allNextVertexIDClusters: [(Int, [Int])]? {
            guard let nextVertices = nextVertices else { return nil }
            var container = [(Int, [Int])]()
            nextVertices.forEach { vertex in
                guard let allNextVertexIDs = vertex.allNextVertexIDs else { return }
                container.append((vertex.pointID, allNextVertexIDs))
            }
            return container
        }

        var allNextVertexIDs: [Int]? {
            guard let nextVertices = nextVertices else { return nil }
            let returnedComplex: [[Int]] = nextVertices.map {
                [$0.pointID] + ($0.allNextVertexIDs ?? [])
            }
            return returnedComplex.reduce([], +)
        }

        static func == (
            lhs: AvatarSkillTreeConfig,
            rhs: AvatarSkillTreeConfig
        )
            -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            // 核心識別屬性
            hasher.combine(pointID)
            hasher.combine(level)
            hasher.combine(avatarID)

            // 其他關鍵屬性
            hasher.combine(pointType)
            hasher.combine(anchor)
            hasher.combine(maxLevel)
            hasher.combine(defaultUnlock)
            hasher.combine(prePoint)
            hasher.combine(iconPath)
            hasher.combine(pointName)
            hasher.combine(pointTriggerKey)

            // 注意：沒有包含 previousVertex 和 nextVertices
            // 因為這些是引用類型且可能導致循環引用
        }
    }
}

extension [DimModels4HSR.AvatarSkillTreeConfig] {
    func hookVertices() {
        forEach { currentVertex in
            guard let prePoint = currentVertex.prePoint.first else { return }
            guard let matched = self.first(where: { $0.pointID == prePoint }) else { return }
            currentVertex.previousVertex = matched
            if matched.nextVertices == nil {
                matched.nextVertices = []
            }
            matched.nextVertices?.append(currentVertex)
        }
    }
}

// MARK: - DimModels4HSR.EquipmentConfig

extension DimModels4HSR {
    struct EquipmentConfig: Hashable, Decodable, Identifiable, NameHashable {
        // MARK: - Equipment

        struct Equipment: Hashable, Decodable {
            let hash: UInt
        }

        let equipmentID: Int
        let release: Bool
        let equipmentName: Equipment
        let rarity: String
        let avatarBaseType: String
        let maxPromotion: Int
        let maxRank: Int
        let expType: Int
        let skillID: Int
        let expProvide: Int
        let coinCost: Int
        let rankUpCostList: [Int]
        let thumbnailPath: String
        let imagePath: String
        let itemRightPanelOffset: [Double]
        let avatarDetailOffset: [Double]
        let battleDialogOffset: [Double]
        let gachaResultOffset: [Double]

        var id: Int { equipmentID }

        var isValid: Bool {
            switch skillID {
            case 7000000 ..< 8000000: false
            default: true
            }
        }

        var nameTextMapHash: UInt {
            equipmentName.hash
        }
    }
}

// MARK: - DimModels4HSR.PlayerIcon

extension DimModels4HSR {
    struct PlayerIcon: Hashable, Decodable, Identifiable {
        let id: Int
        let imagePath: String
    }
}

// MARK: - DimModels4HSR.RelicConfig

extension DimModels4HSR {
    struct RelicConfig: Hashable, Decodable, Identifiable {
        let id: Int
        let setID: Int
        let type: String
        let rarity: String
        let mainAffixGroup: Int
        let subAffixGroup: Int
        let maxLevel: Int
        let expType: Int
        let expProvide: Int
        let coinCost: Int
        let mode: String
    }
}

// MARK: - DimModels4HSR.RelicDataInfo

extension DimModels4HSR {
    struct RelicDataInfo: Hashable, Decodable, Identifiable {
        let setID: Int
        let type: String
        let iconPath: String
        let relicName: String

        var id: String { relicName.suffix(5).description }
    }
}

// MARK: - DimModels4HSR.AvatarRankConfig

extension DimModels4HSR {
    struct AvatarRankConfig: Hashable, Decodable, Identifiable {
        let rankID: Int
        let rank: Int
        let iconPath: String
        let skillAddLevelList: [String: Int]

        var id: Int { rankID }

        var isValid: Bool {
            switch id {
            case 700000 ..< 800000: false
            default: true
            }
        }
    }
}
