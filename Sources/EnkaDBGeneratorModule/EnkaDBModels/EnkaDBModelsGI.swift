// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

// MARK: - EnkaDBModelsGI

public enum EnkaDBModelsGI {}

// MARK: EnkaDBModelsGI.Character

extension EnkaDBModelsGI {
    public typealias CharacterDict = [String: Character]

    public struct Character: Codable, Hashable {
        // MARK: Public

        public var consts: [String]
        public var costumes: [String: Costume]?
        public var element: String
        public var nameTextMapHash: Int
        public var proudMap: [String: Int]
        public var qualityType: String
        public var sideIconName: String
        public var skillOrder: [Int]
        public var skills: [String: String]
        public var weaponType: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
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
    }
}

// MARK: EnkaDBModelsGI.Costume

extension EnkaDBModelsGI {
    public struct Costume: Codable, Hashable {
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
        public var icon: String
    }
}

// MARK: - ProfilePictures

extension EnkaDBModelsGI {
    public typealias ProfilePictureDict = [String: ProfilePicture]

    public struct ProfilePicture: Codable, Hashable {
        public var iconPath: String
    }
}
