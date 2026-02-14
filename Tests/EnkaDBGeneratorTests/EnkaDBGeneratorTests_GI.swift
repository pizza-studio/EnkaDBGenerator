// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import EnkaDBGeneratorModule
import EnkaDBModels
import Foundation
import Testing

// MARK: - EnkaDBGeneratorTestsGI

@Suite(.serialized)
struct EnkaDBGeneratorTestsGI {
    @Test
    func testInitializingDimDB4GI() async throws {
        let jsonGI = try await DimModels4GI.DimDB4GI(withLang: true)
        if let lumine = jsonGI.avatarDB.first(where: { $0.id == 10000007 }) {
            let text = jsonGI.langTable["ja-jp"]?[lumine.nameTextMapHash.description]
            #expect(text == "蛍")
        } else {
            Issue.record("Lumine is missing.")
        }
        let compiledMap = jsonGI.assembleEnkaLangMap()
        #expect(nil != compiledMap["uk"]?["level"])
    }

    @Test
    func testAssemblingEnkaDB4GI() async throws {
        let jsonGI = try await DimModels4GI.DimDB4GI(withLang: false)
        let nonProtagonistCharacterCountRAW: Int = jsonGI.avatarDB.filter {
            Protagonist(rawValue: $0.id) == nil && !$0.isManekinOrManekina
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
        #expect(referenceAnswer == hydroLumine)
        #expect(nonProtagonistCharacterCountFromResult - 2 == nonProtagonistCharacterCountRAW)
        // Profile Pictures.
        let pfpTable = jsonGI.assembleEnkaProfilePictures()
        let cardTable = jsonGI.assembleEnkaNameCards()
        #expect(!pfpTable.isEmpty)
        #expect(!cardTable.isEmpty)
    }
}

private let lumineReferenceEnkaDBCharJSON = """
{
  "Consts" : [
    "UI_Talent_S_PlayerWater_01",
    "UI_Talent_S_PlayerWater_02",
    "UI_Talent_U_PlayerWater_01",
    "UI_Talent_S_PlayerWater_03",
    "UI_Talent_U_PlayerWater_02",
    "UI_Talent_S_PlayerWater_04"
  ],
  "Costumes" : {
    "200701" : {
      "art" : "UI_Costume_PlayerGirlCostumeCWXR",
      "avatarId" : 10000007,
      "icon" : "UI_AvatarIcon_PlayerGirlCostumeCWXR",
      "sideIconName" : "UI_AvatarIcon_Side_PlayerGirlCostumeCWXR"
    }
  },
  "Element" : "Water",
  "NameTextMapHash" : 3816664530,
  "ProudMap" : {
    "100552" : 631,
    "10087" : 632,
    "10088" : 639
  },
  "QualityType" : "QUALITY_ORANGE",
  "SideIconName" : "UI_AvatarIcon_Side_PlayerGirl",
  "SkillOrder" : [
    100552,
    10087,
    10088
  ],
  "Skills" : {
    "100552" : "Skill_A_01",
    "10087" : "Skill_S_PlayerWater_01",
    "10088" : "Skill_E_PlayerWater_01"
  },
  "WeaponType" : "WEAPON_SWORD_ONE_HAND"
}
"""
