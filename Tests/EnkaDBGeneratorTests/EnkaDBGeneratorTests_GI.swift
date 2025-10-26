// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import EnkaDBGeneratorModule
import EnkaDBModels
import Foundation
import XCTest

// MARK: - EnkaDBGeneratorTestsGI

final class EnkaDBGeneratorTestsGI: XCTestCase {
    func testInitializingDimDB4GI() async throws {
        let jsonGI = try await DimModels4GI.DimDB4GI(withLang: true)
        if let lumine = jsonGI.avatarDB.first(where: { $0.id == 10000007 }) {
            let text = jsonGI.langTable["ja-jp"]?[lumine.nameTextMapHash.description]
            XCTAssertNotNil(text)
            XCTAssertEqual(text, "蛍")
        } else {
            assertionFailure("Lumine is missing.")
        }
        let compiledMap = jsonGI.assembleEnkaLangMap()
        XCTAssertNotNil(compiledMap["uk"]?["level"])
    }

    func testAssemblingEnkaDB4GI() async throws {
        let jsonGI = try await DimModels4GI.DimDB4GI(withLang: false)
        let nonProtagonistCharacterCountRAW: Int = jsonGI.avatarDB.filter {
            Protagonist(rawValue: $0.id) == nil && ![10000117, 10000118].contains($0.id)
        }.count
        let summarizedCharacterMap = try jsonGI.assembleEnkaCharacters()
        guard let hydroLumine = summarizedCharacterMap["10000007-703"] else {
            assertionFailure("WaterLumine is Missing.")
            exit(1)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let encoded = try encoder.encode(hydroLumine)
        if let encodedStr = String(data: encoded, encoding: .utf8) {
            print("===========================")
            print(encodedStr)
            print("===========================")
        }
        let referenceAnswer = try JSONDecoder().decode(
            EnkaDBModelsGI.Character.self, from: lumineReferenceEnkaDBCharJSON.data(using: .utf8)!
        )
        let nonProtagonistCharacterCountFromResult = summarizedCharacterMap.filter {
            !$0.key.contains("-")
        }.count
        XCTAssertEqual(referenceAnswer, hydroLumine)
        XCTAssertEqual(nonProtagonistCharacterCountFromResult - 2, nonProtagonistCharacterCountRAW)
        // Profile Pictures.
        let pfpTable = jsonGI.assembleEnkaProfilePictures()
        let cardTable = jsonGI.assembleEnkaNameCards()
        XCTAssertFalse(pfpTable.isEmpty)
        XCTAssertFalse(cardTable.isEmpty)
    }
}

private let lumineReferenceEnkaDBCharJSON = """
{
  "Element": "Water",
  "Consts": [
    "/ui/UI_Talent_S_PlayerWater_01.png",
    "/ui/UI_Talent_S_PlayerWater_02.png",
    "/ui/UI_Talent_U_PlayerWater_01.png",
    "/ui/UI_Talent_S_PlayerWater_03.png",
    "/ui/UI_Talent_U_PlayerWater_02.png",
    "/ui/UI_Talent_S_PlayerWater_04.png"
  ],
  "SkillOrder": [100552, 10087, 10088],
  "Skills": {
    "10087": "/ui/Skill_S_PlayerWater_01.png",
    "10088": "/ui/Skill_E_PlayerWater_01.png",
    "100552": "/ui/Skill_A_01.png"
  },
  "NameTextMapHash": 3816664530,
  "ProudMap": { "10087": 632, "10088": 639, "100552": 631 },
  "SideIconName": "/ui/UI_AvatarIcon_Side_PlayerGirl.png",
  "QualityType": "QUALITY_ORANGE",
  "WeaponType": "WEAPON_SWORD_ONE_HAND",
  "BaseProps": {
    "1": 911.791,
    "4": 17.808,
    "7": 57.225,
    "20": 0.05,
    "22": 0.5,
    "28": 0
  },
  "PropGrowCurves": {
    "1": 104,
    "4": 204,
    "7": 104
  },
  "PromoteProps": [
    {"1": 0, "4": 0, "7": 0},
    {"1": 681.15454, "4": 13.3038, "7": 42.75},
    {"1": 1165.1328, "4": 22.7565, "7": 73.125},
    {"1": 1810.4371, "4": 35.3601, "7": 113.625},
    {"1": 2294.4153, "4": 44.8128, "7": 144.0},
    {"1": 2778.3936, "4": 54.2655, "7": 174.375},
    {"1": 3262.3718, "4": 63.7182, "7": 204.75}
  ]
}
"""
