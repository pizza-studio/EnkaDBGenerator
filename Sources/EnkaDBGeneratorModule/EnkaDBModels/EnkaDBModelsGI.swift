// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

// MARK: - EnkaDBModelsGI

enum EnkaDBModelsGI {}

// MARK: EnkaDBModelsGI.Character

extension EnkaDBModelsGI {
    typealias CharacterDict = [String: Character]

    struct Character: Codable, Hashable {
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

        var consts: [String]
        var costumes: [String: Costume]?
        var element: String
        var nameTextMapHash: Int
        var proudMap: [String: Int]
        var qualityType: String
        var sideIconName: String
        var skillOrder: [Int]
        var skills: [String: String]
        var weaponType: String
    }
}

// MARK: EnkaDBModelsGI.Costume

extension EnkaDBModelsGI {
    struct Costume: Codable, Hashable {
        var art: String
        var avatarId: Int
        var icon: String
        var sideIconName: String
    }
}

// MARK: - Affixes

extension EnkaDBModelsGI {
    typealias AffixDict = [String: Affix]

    struct Affix: Codable, Hashable {
        var efficiency: Double
        var position: Int
        var propType: String
    }
}

// MARK: - NameCards

extension EnkaDBModelsGI {
    typealias NameCardDict = [String: NameCard]

    struct NameCard: Codable, Hashable {
        var icon: String
    }
}

// MARK: - ProfilePictures

extension EnkaDBModelsGI {
    typealias ProfilePictureDict = [String: ProfilePicture]

    struct ProfilePicture: Codable, Hashable {
        var iconPath: String
    }
}
