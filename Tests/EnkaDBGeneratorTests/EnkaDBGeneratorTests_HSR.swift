// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

@testable import EnkaDBGeneratorModule
import Foundation
import XCTest

// MARK: - EnkaDBGeneratorTestsHSR

final class EnkaDBGeneratorTestsHSR: XCTestCase {
    func testInitializingDimDB4HSR() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: true)
        if let physicalStelle = jsonGI.avatarDB.first(where: { $0.id == 8002 }) {
            let text = jsonGI.langTable["ja-jp"]?[physicalStelle.nameTextMapHash.description]
            XCTAssertNotNil(text)
            XCTAssertEqual(text, "星")
        } else {
            assertionFailure("Stelle is missing.")
        }
        let compiledMap = jsonGI.assembleEnkaLangMap()
        XCTAssertNotNil(compiledMap["zh-tw"]?["su"])
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_Characters() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = try jsonGI.assembleEnkaCharacters()
        guard let matched = assembled["1001"] else {
            assertionFailure("Mitsuki Nanoka (Cryo) is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
          "AvatarName": { "Hash": -531793651 },
          "AvatarFullName": { "Hash": -1063124016 },
          "Rarity": 4, "Element": "Ice", "AvatarBaseType": "Knight",
          "AvatarSideIconPath": "SpriteOutput/AvatarRoundIcon/1001.png",
          "ActionAvatarHeadIconPath": "SpriteOutput/AvatarIconTeam/1001B.png",
          "AvatarCutinFrontImgPath": "SpriteOutput/AvatarDrawCard/1001.png",
          "RankIDList": [ 100101, 100102, 100103, 100104, 100105, 100106 ],
          "SkillList": [ 100101, 100102, 100103, 100104, 100106, 100107 ]
        }
        """
        let expected = try JSONDecoder().decode(
            EnkaDBModelsHSR.Character.self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_Weapons() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = try jsonGI.assembleEnkaWeapons()
        guard let lightCone20K = assembled["20000"] else {
            assertionFailure("LightCone 20000 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
            "Rarity": 3,
            "AvatarBaseType": "Rogue",
            "EquipmentName": {
              "Hash": -234052537
            },
            "ImagePath": "SpriteOutput/LightConeFigures/20000.png"
          }
        """
        let expected = try JSONDecoder().decode(
            EnkaDBModelsHSR.Weapon.self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(lightCone20K, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(lightCone20K)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_Relics() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = try jsonGI.assembleEnkaArtifactRelics()
        guard let matched = assembled["31011"] else {
            assertionFailure("Artifact 31011 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
            "Rarity": 2,
            "Type": "HEAD",
            "MainAffixGroup": 21,
            "SubAffixGroup": 2,
            "Icon": "SpriteOutput/ItemIcon/RelicIcons/IconRelic_101_1.png",
            "SetID": 101
          }
        """
        let expected = try JSONDecoder().decode(
            EnkaDBModelsHSR.Artifact.self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_Skills() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = try jsonGI.assembleEnkaSkills()
        guard let matched = assembled["1001001"] else {
            assertionFailure("Skill 1001001 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
            "IconPath": "SpriteOutput/SkillIcons/SkillIcon_1001_Normal.png",
            "PointType": 2
          }
        """
        let expected = try JSONDecoder().decode(
            EnkaDBModelsHSR.Skill.self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_Ranks() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = try jsonGI.assembleEnkaRanks()
        guard let matched = assembled["100101"] else {
            assertionFailure("Skill Rank 100101 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
            "IconPath": "SpriteOutput/SkillIcons/SkillIcon_1001_Rank1.png",
            "SkillAddLevelList": {}
          }
        """
        let expected = try JSONDecoder().decode(
            EnkaDBModelsHSR.SkillRank.self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_SkillTree() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = try jsonGI.assembleEnkaSkillTree()
        guard let matched = assembled["1001"] else {
            assertionFailure("Mitsuki Nanoka (Cryo) is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
          "0" : ["1001001", "1001002", "1001003", "1001004", "1001007"],
          "1" : [
            ["1001103", "1001208", "1001209", "1001210"],
            ["1001101", "1001202", "1001203"],
            ["1001102", "1001205", "1001206"],
            ["1001201", "1001204", "1001207"]
          ]
        }
        """
        let expected = try JSONDecoder().decode(
            EnkaDBModelsHSR.SkillTree.self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}

extension EnkaDBGeneratorTestsHSR {
    func testAssemblingEnkaDB4HSR_Meta_AvatarPromotion() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeRawAvatarMetaDict()
        guard let matched = assembled["1001"] else {
            assertionFailure("Mitsuki Nanoka (Cryo) is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
        "0":{"HPBase":144,"HPAdd":7.2,"AttackBase":69.6,"AttackAdd":3.48,"DefenceBase":78,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150},
        "1":{"HPBase":201.6,"HPAdd":7.2,"AttackBase":97.44,"AttackAdd":3.48,"DefenceBase":109.2,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150},
        "2":{"HPBase":259.2,"HPAdd":7.2,"AttackBase":125.28,"AttackAdd":3.48,"DefenceBase":140.4,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150},
        "3":{"HPBase":316.8,"HPAdd":7.2,"AttackBase":153.12,"AttackAdd":3.48,"DefenceBase":171.6,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150},
        "4":{"HPBase":374.4,"HPAdd":7.2,"AttackBase":180.96,"AttackAdd":3.48,"DefenceBase":202.8,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150},
        "5":{"HPBase":432,"HPAdd":7.2,"AttackBase":208.8,"AttackAdd":3.48,"DefenceBase":234,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150},
        "6":{"HPBase":489.6,"HPAdd":7.2,"AttackBase":236.64,"AttackAdd":3.48,"DefenceBase":265.2,
        "DefenceAdd":3.9,"SpeedBase":101,"CriticalChance":0.05,"CriticalDamage":0.5,"BaseAggro":150}
        }
        """
        let expected = try JSONDecoder().decode(
            [String: EnkaDBModelsHSR.Meta.AvatarMeta].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }

    func testAssemblingEnkaDB4HSR_Meta_EquipPromotion() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeRawEquipmentMetaDict()
        guard let matched = assembled["20000"] else {
            assertionFailure("Light Cone 20000 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
        "0":{"BaseHP":38.4,"HPAdd":5.76,"BaseAttack":14.4,"AttackAdd":2.16,"BaseDefence":12,"DefenceAdd":1.8},
        "1":{"BaseHP":84.48,"HPAdd":5.76,"BaseAttack":31.68,"AttackAdd":2.16,"BaseDefence":26.4,"DefenceAdd":1.8},
        "2":{"BaseHP":145.92,"HPAdd":5.76,"BaseAttack":54.72,"AttackAdd":2.16,"BaseDefence":45.6,"DefenceAdd":1.8},
        "3":{"BaseHP":207.36,"HPAdd":5.76,"BaseAttack":77.76,"AttackAdd":2.16,"BaseDefence":64.8,"DefenceAdd":1.8},
        "4":{"BaseHP":268.8,"HPAdd":5.76,"BaseAttack":100.8,"AttackAdd":2.16,"BaseDefence":84,"DefenceAdd":1.8},
        "5":{"BaseHP":330.24,"HPAdd":5.76,"BaseAttack":123.84,"AttackAdd":2.16,"BaseDefence":103.2,"DefenceAdd":1.8},
        "6":{"BaseHP":391.68,"HPAdd":5.76,"BaseAttack":146.88,"AttackAdd":2.16,"BaseDefence":122.4,"DefenceAdd":1.8}
        }
        """
        let expected = try JSONDecoder().decode(
            [String: EnkaDBModelsHSR.Meta.EquipmentMeta].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }

    func testAssemblingEnkaDB4HSR_Meta_EquipSkill() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeRawEquipSkillMetaDict()
        guard let matched = assembled["20003"] else {
            assertionFailure("Equipment Skill 20003 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
        "1":{"props":{"DefenceAddedRatio":0.16}},"2":{"props":{"DefenceAddedRatio":0.2}},
        "3":{"props":{"DefenceAddedRatio":0.24}},"4":{"props":{"DefenceAddedRatio":0.28}},
        "5":{"props":{"DefenceAddedRatio":0.32}}
        }
        """
        let expected = try JSONDecoder().decode(
            [String: [String: [String: Double]]].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }

    func testAssemblingEnkaDB4HSR_Meta_RelicMainAffix() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeRelicMainAffixTable()
        guard let matched = assembled["23"] else {
            assertionFailure("Artifact Main-Affix Group 23 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
        "1":{"BaseValue":0.027648,"LevelAdd":0.009677,"Property":"HPAddedRatio"},
        "2":{"BaseValue":0.027648,"LevelAdd":0.009677,"Property":"AttackAddedRatio"},
        "3":{"BaseValue":0.034560002,"LevelAdd":0.012096001,"Property":"DefenceAddedRatio"},
        "4":{"BaseValue":0.020736001,"LevelAdd":0.007258,"Property":"CriticalChanceBase"},
        "5":{"BaseValue":0.041472,"LevelAdd":0.014515,"Property":"CriticalDamageBase"},
        "6":{"BaseValue":0.022118,"LevelAdd":0.0077410005,"Property":"HealRatioBase"},
        "7":{"BaseValue":0.027648,"LevelAdd":0.009677,"Property":"StatusProbabilityBase"}
        }
        """
        let expected = try JSONDecoder().decode(
            [String: EnkaDBModelsHSR.Meta.RawRelicDB.MainAffix].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }

    func testAssemblingEnkaDB4HSR_Meta_RelicSubAffix() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeRelicSubAffixTable()
        guard let matched = assembled["2"] else {
            assertionFailure("Artifact Sub-Affix Group 2 is missing.")
            exit(1)
        }
        let expectedJSON = """
        {
        "1":{"BaseValue":13.548016,"Property":"HPDelta","StepValue":1.693502},
        "2":{"BaseValue":6.774008,"Property":"AttackDelta","StepValue":0.846751},
        "3":{"BaseValue":6.774008,"Property":"DefenceDelta","StepValue":0.846751},
        "4":{"BaseValue":0.013824001,"Property":"HPAddedRatio","StepValue":0.0017280006},
        "5":{"BaseValue":0.013824001,"Property":"AttackAddedRatio","StepValue":0.0017280006},
        "6":{"BaseValue":0.017280001,"Property":"DefenceAddedRatio","StepValue":0.0021600004},
        "7":{"BaseValue":1,"Property":"SpeedDelta","StepValue":0.1},
        "8":{"BaseValue":0.010368001,"Property":"CriticalChanceBase","StepValue":0.0012960008},
        "9":{"BaseValue":0.020736001,"Property":"CriticalDamageBase","StepValue":0.0025920009},
        "10":{"BaseValue":0.013824001,"Property":"StatusProbabilityBase","StepValue":0.0017280006},
        "11":{"BaseValue":0.013824001,"Property":"StatusResistanceBase","StepValue":0.0017280006},
        "12":{"BaseValue":0.020736001,"Property":"BreakDamageAddedRatioBase","StepValue":0.0025920009
        }
        }
        """
        let expected = try JSONDecoder().decode(
            [String: EnkaDBModelsHSR.Meta.RawRelicDB.SubAffix].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }

    func testAssemblingEnkaDB4HSR_Meta_RelicSetSkill() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeRelicSetSkillTable()
        guard let matched = assembled["101"] else {
            assertionFailure("Artifact Skill Set 101 is missing.")
            exit(1)
        }
        let expectedJSON = #"{"2":{"props":{"HealRatioBase":0.1}},"4":{"props":{}}}"#
        let expected = try JSONDecoder().decode(
            [String: [String: [String: Double]]].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }

    func testAssemblingEnkaDB4HSR_Meta_SkillTreeMeta() async throws {
        let jsonGI = try await DimModels4HSR.DimDB4HSR(withLang: false)
        let assembled = jsonGI.makeSkillTreeMetaDict()
        guard let matched = assembled["1001201"] else {
            assertionFailure("Skill Tree Meta 1001201 is missing.")
            exit(1)
        }
        let expectedJSON = #"{"1":{"props":{"IceAddedRatio":0.032}}}"#
        let expected = try JSONDecoder().decode(
            [String: [String: [String: Double]]].self,
            from: expectedJSON.data(using: .utf8) ?? .init([])
        )
        XCTAssertEqual(matched, expected)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(matched)
        guard let str = String(data: data, encoding: .utf8) else {
            assertionFailure("Encoding Error.")
            exit(1)
        }
        print(str)
    }
}
