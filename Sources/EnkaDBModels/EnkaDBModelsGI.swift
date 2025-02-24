// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - EnkaDBModelsGI

public enum EnkaDBModelsGI {}

// MARK: EnkaDBModelsGI.Character

extension EnkaDBModelsGI {
    public typealias CharacterDict = [String: Character]

    public struct Character: Codable, Hashable {
        // MARK: Lifecycle

        public init(
            consts: [String],
            costumes: [String: EnkaDBModelsGI.Costume]? = nil,
            element: String,
            nameTextMapHash: UInt,
            proudMap: [String: Int],
            qualityType: String,
            sideIconName: String,
            skillOrder: [Int],
            skills: [String: String],
            weaponType: String
        ) {
            self.consts = consts
            self.costumes = costumes
            self.element = element
            self.nameTextMapHash = nameTextMapHash
            self.proudMap = proudMap
            self.qualityType = qualityType
            self.sideIconName = sideIconName
            self.skillOrder = skillOrder
            self.skills = skills
            self.weaponType = weaponType
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case element = "Element"
            case consts = "Consts"
            case skillOrder = "SkillOrder"
            case skills = "Skills"
            case proudMap = "ProudMap"
            case nameTextMapHash = "NameTextMapHash"
            case sideIconName = "SideIconName"
            case qualityType = "QualityType"
            case weaponType = "WeaponType"
            case costumes = "Costumes"
        }

        public var consts: [String]
        public var costumes: [String: Costume]?
        public var element: String
        public var nameTextMapHash: UInt
        public var proudMap: [String: Int]
        public var qualityType: String
        public var sideIconName: String
        public var skillOrder: [Int]
        public var skills: [String: String]
        public var weaponType: String
    }
}

// MARK: EnkaDBModelsGI.Costume

extension EnkaDBModelsGI {
    public struct Costume: Codable, Hashable {
        // MARK: Lifecycle

        public init(art: String, avatarId: Int, icon: String, sideIconName: String) {
            self.art = art
            self.avatarId = avatarId
            self.icon = icon
            self.sideIconName = sideIconName
        }

        // MARK: Public

        public var art: String
        public var avatarId: Int
        public var icon: String
        public var sideIconName: String
    }
}

// MARK: - Affixes

extension EnkaDBModelsGI {
    public typealias AffixDict = [String: Affix]

    public struct Affix: Codable, Hashable {
        public var efficiency: Double
        public var position: Int
        public var propType: String
    }
}

// MARK: - NameCards

extension EnkaDBModelsGI {
    public typealias NameCardDict = [String: NameCard]

    public struct NameCard: Codable, Hashable {
        // MARK: Lifecycle

        public init(icon: String) {
            self.icon = icon
        }

        // MARK: Public

        public var icon: String
    }
}

// MARK: - ProfilePictures

extension EnkaDBModelsGI {
    public typealias ProfilePictureDict = [String: ProfilePicture]

    public struct ProfilePicture: Codable, Hashable {
        // MARK: Lifecycle

        public init(iconPath: String) {
            self.iconPath = iconPath
        }

        // MARK: Public

        public var iconPath: String
    }
}
