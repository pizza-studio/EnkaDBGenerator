// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

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
            EnkaDBGenerator.Protagonist(rawValue: $0.id) == nil
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
    "UI_Talent_S_PlayerWater_01",
    "UI_Talent_S_PlayerWater_02",
    "UI_Talent_U_PlayerWater_01",
    "UI_Talent_S_PlayerWater_03",
    "UI_Talent_U_PlayerWater_02",
    "UI_Talent_S_PlayerWater_04"
  ],
  "SkillOrder": [100552, 10087, 10088],
  "Skills": {
    "10087": "Skill_S_PlayerWater_01",
    "10088": "Skill_E_PlayerWater_01",
    "100552": "Skill_A_01"
  },
  "NameTextMapHash": 3816664530,
  "ProudMap": { "10087": 632, "10088": 639, "100552": 631 },
  "SideIconName": "UI_AvatarIcon_Side_PlayerGirl",
  "QualityType": "QUALITY_ORANGE",
  "WeaponType": "WEAPON_SWORD_ONE_HAND"
}
"""
