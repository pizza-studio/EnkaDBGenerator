// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels

extension DimModels4GI.DimDB4GI {
    func packObjects() throws -> [String: any Encodable] {
        var result = [String: any Encodable]()
        /// Omitting `affixes.json` which is suspected to be the artifact rating model for Enka.Network website.
        /// The calculation method of its `efficiency` field is still unknown.
        result["locs.json"] = assembleEnkaLangMap()
        result["avatars.json"] = try assembleEnkaCharacters()
        result["namecards.json"] = assembleEnkaNameCards()
        result["pfps.json"] = assembleEnkaProfilePictures()
        return result
    }
}

extension DimModels4GI.DimDB4GI {
    /// Helper function to format icon paths with /ui/ prefix and .png extension
    private func formatIconPath(_ iconName: String) -> String {
        "/ui/\(iconName).png"
    }
    
    func assembleEnkaCharacters() throws -> EnkaDBModelsGI.CharacterDict {
        var result = EnkaDBModelsGI.CharacterDict()
        try avatarDB.forEach { avatar in
            var skillDepotIDs = [avatar.skillDepotId]
            let isProtagoinst = !avatar.candSkillDepotIds.isEmpty
            let isMannequin = [10000117, 10000118].contains(avatar.id)
            
            if isProtagoinst { 
                skillDepotIDs = avatar.candSkillDepotIds
                // For mannequins, skip the first depot ID (X1701, X1801) as they don't have valid elements
                if isMannequin {
                    skillDepotIDs = Array(skillDepotIDs.dropFirst())
                }
            }
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
                    guard let icon = self.constellationDB.first(where: { $0.talentId == talentID })?.icon else { return nil }
                    return formatIconPath(icon)
                }
                // Costumes.
                var finalCostumes: [String: EnkaDBModelsGI.Costume]?
                let rawCostumes = self.costumeDB.filter {
                    $0.characterId == avatar.id && $0.isValid
                }
                if !rawCostumes.isEmpty {
                    finalCostumes = [String: EnkaDBModelsGI.Costume]()
                    rawCostumes.forEach { skin in
                        guard let art = skin.art, let frontIconName = skin.frontIconName else { return }
                        guard let sideIconName = skin.sideIconName else { return }
                        finalCostumes?[skin.skinId.description] = EnkaDBModelsGI.Costume(
                            art: formatIconPath(art),
                            avatarId: skin.characterId,
                            icon: formatIconPath(frontIconName),
                            sideIconName: formatIconPath(sideIconName)
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
                var skillIDsToPurge = Set<Int>()
                finalSkillOrder.forEach { currentSkillID in
                    guard let matchedSkill = self.skillDB.first(where: { $0.id == currentSkillID })
                    else {
                        print(
                            "[Assembler Notice] Skill \(currentSkillID) mismatch for GI character \(charUUID), skipping."
                        )
                        skillIDsToPurge.insert(currentSkillID)
                        return
                    }
                    guard matchedSkill.proudSkillGroupId != 0 else {
                        skillIDsToPurge.insert(currentSkillID)
                        return
                    }
                    finalSkills[currentSkillID.description] = formatIconPath(matchedSkill.skillIcon)
                    finalProudMap[currentSkillID.description] = matchedSkill.proudSkillGroupId
                }
                finalSkillOrder.removeAll { skillIDsToPurge.contains($0) }
                let finalNameTextMapHash = avatar.nameTextMapHash
                let finalQualityType = avatar.qualityType
                let finalSideIconName = formatIconPath(avatar.sideIconName)
                let finalWeaponType = avatar.weaponType
                
                // BaseProps, PropGrowCurves, and PromoteProps
                var finalBaseProps: [String: Double]?
                var finalPropGrowCurves: [String: Int]?
                var finalPromoteProps: [[String: Double]]?
                
                // Map fight prop types to numeric keys
                let propTypeMap: [String: String] = [
                    "FIGHT_PROP_BASE_HP": "1",
                    "FIGHT_PROP_BASE_ATTACK": "4",
                    "FIGHT_PROP_BASE_DEFENSE": "7",
                    "FIGHT_PROP_CRITICAL": "20",
                    "FIGHT_PROP_CRITICAL_HURT": "22",
                    "FIGHT_PROP_CHARGE_EFFICIENCY": "28"
                ]
                
                // Build BaseProps from avatar data
                if let hpBase = avatar.hpBase, let attackBase = avatar.attackBase, let defenseBase = avatar.defenseBase {
                    finalBaseProps = [
                        "1": hpBase,
                        "4": attackBase,
                        "7": defenseBase,
                        "20": avatar.critical ?? 0.05,
                        "22": avatar.criticalHurt ?? 0.5,
                        "28": 0
                    ]
                }
                
                // Build PropGrowCurves
                if let growCurves = avatar.propGrowCurves {
                    finalPropGrowCurves = [:]
                    for curve in growCurves {
                        if let propKey = propTypeMap[curve.type] {
                            // Map curve names to IDs (simplified mapping)
                            let curveId: Int
                            if curve.growCurve.contains("HP_S5") {
                                curveId = 105
                            } else if curve.growCurve.contains("ATTACK_S5") {
                                curveId = 205
                            } else if curve.growCurve.contains("HP_S4") {
                                curveId = 104
                            } else if curve.growCurve.contains("ATTACK_S4") {
                                curveId = 204
                            } else {
                                curveId = 105 // Default
                            }
                            finalPropGrowCurves?[propKey] = curveId
                        }
                    }
                }
                
                // Build PromoteProps from promotion data
                if let promoteId = avatar.avatarPromoteId {
                    let promoteData = self.avatarPromoteDB.filter { $0.avatarPromoteId == promoteId }.sorted { ($0.promoteLevel ?? 0) < ($1.promoteLevel ?? 0) }
                    if !promoteData.isEmpty {
                        finalPromoteProps = promoteData.map { promote in
                            var propsDict: [String: Double] = [:]
                            if let addProps = promote.addProps {
                                for prop in addProps {
                                    if let propType = prop.propType, let value = prop.value, let propKey = propTypeMap[propType] {
                                        propsDict[propKey] = value
                                    }
                                }
                            }
                            return propsDict
                        }
                    }
                }
                
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
                    weaponType: finalWeaponType,
                    baseProps: finalBaseProps,
                    propGrowCurves: finalPropGrowCurves,
                    promoteProps: finalPromoteProps
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
            result[currentPFP.id.description] = .init(iconPath: formatIconPath(currentPFP.iconPath))
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
                icon: formatIconPath(iconName)
            )
        }
        return result
    }
}
