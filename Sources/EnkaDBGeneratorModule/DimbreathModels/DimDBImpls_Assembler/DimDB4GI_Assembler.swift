// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels

extension DimModels4GI.DimDB4GI {
    func packObjects() throws -> [String: any Encodable] {
        var result = [String: any Encodable]()
        /// Omitting `affixes.json` which is suspected to be the artifact rating model for Enka.Network website.
        /// The calculation method of its `efficiency` field is still unknown.
        result["loc.json"] = assembleEnkaLangMap()
        result["characters.json"] = try assembleEnkaCharacters()
        result["namecards.json"] = assembleEnkaNameCards()
        result["pfps.json"] = assembleEnkaProfilePictures()
        return result
    }
}

extension DimModels4GI.DimDB4GI {
    func assembleEnkaCharacters() throws -> EnkaDBModelsGI.CharacterDict {
        var result = EnkaDBModelsGI.CharacterDict()
        try avatarDB.forEach { avatar in
            var skillDepotIDs = [avatar.skillDepotId]
            let isProtagoinst = !avatar.candSkillDepotIds.isEmpty
            if isProtagoinst { skillDepotIDs = avatar.candSkillDepotIds }
            try skillDepotIDs.forEach { skillDepotID in
                /// Final Index ID for each character, distinguishing protagonists in different Elements.
                let charUUID = isProtagoinst ? "\(avatar.id)-\(skillDepotID)" : avatar.id.description
                guard let skillDepotTable = self.skillDepotDB.first(where: { $0.id == skillDepotID }) else {
                    throw EnkaDBGenerator.EDBGError.assemblerError(
                        msg: "Depot table missing for GI character \(charUUID), aborting."
                    )
                }
                // Constellations. Vary among different Elements of the protagonist.
                let finalConsts: [String] = (skillDepotTable.talents ?? []).compactMap { talentID in
                    self.constellationDB.first(where: { $0.talentId == talentID })?.icon
                }
                // Costumes.
                var finalCostumes: [String: EnkaDBModelsGI.Costume]?
                let rawCostumes = self.costumeDB.filter { $0.characterId == avatar.id }
                if !rawCostumes.isEmpty {
                    finalCostumes = [String: EnkaDBModelsGI.Costume]()
                    rawCostumes.forEach { skin in
                        guard let art = skin.art, let frontIconName = skin.frontIconName else { return }
                        guard let sideIconName = skin.sideIconName else { return }
                        finalCostumes?[skin.skinId.description] = EnkaDBModelsGI.Costume(
                            art: art,
                            avatarId: skin.characterId,
                            icon: frontIconName,
                            sideIconName: sideIconName
                        )
                    }
                    if finalCostumes?.isEmpty ?? false {
                        finalCostumes = nil
                    }
                }
                // Element. We bet that every character in showcase has a valid Teyvat Element type.
                guard let energySkillID = skillDepotTable.energySkill,
                      let energySkill = self.skillDB.first(where: { $0.id == energySkillID }),
                      let finalCharacterElement = energySkill.costElemType
                else {
                    print(
                        "[Assembler Notice] Elemental Burst missing for GI character \(charUUID), skipping."
                    )
                    return
                }
                // SkillOrder.
                var finalSkillOrder: [Int] = (skillDepotTable.skills ?? []).filter { $0 != 0 }
                    + [skillDepotTable.energySkill].compactMap { $0 }
                // ProudMap and Skills.
                var finalProudMap: [String: Int] = [:]
                var finalSkills: [String: String] = [:]
                var skillIDsToPurge = [Int]()
                finalSkillOrder.forEach { currentSkillID in
                    guard let matchedSkill = self.skillDB.first(where: { $0.id == currentSkillID })
                    else {
                        print(
                            "[Assembler Notice] Skill \(currentSkillID) mismatch for GI character \(charUUID), skipping."
                        )
                        skillIDsToPurge.append(currentSkillID)
                        return
                    }
                    finalSkills[currentSkillID.description] = matchedSkill.skillIcon
                    finalProudMap[currentSkillID.description] = matchedSkill.proudSkillGroupId
                }
                finalSkillOrder.removeAll { skillIDsToPurge.contains($0) }
                let finalNameTextMapHash = avatar.nameTextMapHash
                let finalQualityType = avatar.qualityType
                let finalSideIconName = avatar.sideIconName
                let finalWeaponType = avatar.weaponType
                // Assembling the results.
                let assembled = EnkaDBModelsGI.Character(
                    consts: finalConsts,
                    costumes: finalCostumes,
                    element: finalCharacterElement,
                    nameTextMapHash: finalNameTextMapHash,
                    proudMap: finalProudMap,
                    qualityType: finalQualityType,
                    sideIconName: finalSideIconName,
                    skillOrder: finalSkillOrder,
                    skills: finalSkills,
                    weaponType: finalWeaponType
                )
                result[charUUID] = assembled
                if [504, 704].contains(skillDepotID) {
                    // Use the Anemo protagonist as the fallback value.
                    result[avatar.id.description] = assembled
                }
            }
        }
        return result
    }
}

extension DimModels4GI.DimDB4GI {
    func assembleEnkaProfilePictures() -> EnkaDBModelsGI.ProfilePictureDict {
        var result = EnkaDBModelsGI.ProfilePictureDict()
        profilePictureDB.forEach { currentPFP in
            result[currentPFP.id.description] = .init(iconPath: currentPFP.iconPath)
        }
        return result
    }
}

extension DimModels4GI.DimDB4GI {
    func assembleEnkaNameCards() -> EnkaDBModelsGI.NameCardDict {
        var result = EnkaDBModelsGI.NameCardDict()
        namecardDB.forEach { currentNameCard in
            var iconName = currentNameCard.picPath?.first { $0.hasSuffix("_P") }
            if iconName == nil, let iconStr = currentNameCard.icon {
                iconName = "\(iconStr)_P"
            }
            guard let iconName else { return }
            result[currentNameCard.id.description] = EnkaDBModelsGI.NameCard(
                icon: iconName
            )
        }
        return result
    }
}
