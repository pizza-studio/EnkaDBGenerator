// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

extension DimModels4HSR.DimDB4HSR {
    func packObjects() throws -> [String: any Encodable] {
        var result = [String: any Encodable]()
        result["honker_avatars.json"] = assembleEnkaProfileAatars()
        result["honker_characters.json"] = try assembleEnkaCharacters()
        result["honker_meta.json"] = try assembleEnkaMeta()
        result["honker_ranks.json"] = try assembleEnkaRanks()
        result["honker_relics.json"] = try assembleEnkaArtifactRelics()
        result["honker_skills.json"] = try assembleEnkaSkills()
        result["honker_skilltree.json"] = try assembleEnkaSkillTree()
        result["honker_weps.json"] = try assembleEnkaWeapons()
        result["hsr.json"] = assembleEnkaLangMap()
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_avatars.json`.
    func assembleEnkaProfileAatars() -> EnkaDBModelsHSR.ProfileAvatarDict {
        var result = EnkaDBModelsHSR.ProfileAvatarDict()
        profilePictureDB.forEach { currentPFP in
            result[currentPFP.id.description] = .init(icon: currentPFP.imagePath)
        }
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_avatars.json`.
    func assembleEnkaCharacters() throws -> EnkaDBModelsHSR.CharacterDict {
        var result = EnkaDBModelsHSR.CharacterDict()
        try avatarDB.forEach { currentAvatar in
            let charUUID = currentAvatar.id.description
            guard let rarityLevelString = currentAvatar.rarity.last,
                  let rarityLevel = Int(rarityLevelString.description)
            else {
                throw EnkaDBGenerator.EDBGError.assemblerError(
                    msg: "Rarity level mismatch for HSR character \(charUUID), aborting."
                )
            }
            // Assembling the results.
            let assembled = EnkaDBModelsHSR.Character(
                avatarName: .init(hash: currentAvatar.avatarName.hash),
                avatarFullName: .init(hash: currentAvatar.avatarFullName.hash),
                rarity: rarityLevel,
                element: currentAvatar.damageType,
                avatarBaseType: currentAvatar.avatarBaseType, // Lifepath.
                avatarSideIconPath: currentAvatar.avatarSideIconPath.replacingOccurrences(
                    of: "Avatar/", with: ""
                ),
                actionAvatarHeadIconPath: currentAvatar.actionAvatarHeadIconPath,
                avatarCutinFrontImgPath: currentAvatar.avatarCutinFrontImgPath,
                rankIDList: currentAvatar.rankIDList,
                skillList: currentAvatar.skillList
            )
            result[charUUID] = assembled
        }
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_weps.json`.
    func assembleEnkaWeapons() throws -> EnkaDBModelsHSR.WeaponsDict {
        var result = EnkaDBModelsHSR.WeaponsDict()
        try equipmentDB.forEach { currentWeapon in
            let equipUUID = currentWeapon.id.description
            guard let rarityLevelString = currentWeapon.rarity.last,
                  let rarityLevel = Int(rarityLevelString.description)
            else {
                throw EnkaDBGenerator.EDBGError.assemblerError(
                    msg: "Rarity level mismatch for HSR weapon \(equipUUID), aborting."
                )
            }
            // Assembling the results.
            let assembled = EnkaDBModelsHSR.Weapon(
                rarity: rarityLevel,
                avatarBaseType: currentWeapon.avatarBaseType,
                equipmentName: .init(hash: currentWeapon.equipmentName.hash),
                imagePath: currentWeapon.imagePath.replacingOccurrences(
                    of: "LightConeMaxFigures",
                    with: "LightConeFigures"
                )
            )
            result[equipUUID] = assembled
        }
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_relics.json`.
    func assembleEnkaArtifactRelics() throws -> EnkaDBModelsHSR.ArtifactsDict {
        var result = EnkaDBModelsHSR.ArtifactsDict()
        try relicDB.forEach { currentArtifact in
            let artifactUUID = currentArtifact.id.description
            guard let rarityLevelString = currentArtifact.rarity.last,
                  let rarityLevel = Int(rarityLevelString.description)
            else {
                throw EnkaDBGenerator.EDBGError.assemblerError(
                    msg: "Rarity level mismatch for HSR artifact \(artifactUUID), aborting."
                )
            }

            let matchedSetData = relicDataInfoDB.first {
                $0.setID == currentArtifact.setID && $0.type == currentArtifact.type
            }
            guard let matchedSetData else {
                print(
                    "[Assembler Notice] Artifact Set data mismatch for HSR artifact \(artifactUUID), skipping."
                )
                return
            }

            // Assembling the results.
            let assembled = EnkaDBModelsHSR.Artifact(
                type: currentArtifact.type,
                rarity: rarityLevel,
                mainAffixGroup: currentArtifact.mainAffixGroup,
                subAffixGroup: currentArtifact.subAffixGroup,
                icon: matchedSetData.iconPath,
                setID: currentArtifact.setID
            )
            result[artifactUUID] = assembled
        }
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_skills.json`.
    func assembleEnkaSkills() throws -> EnkaDBModelsHSR.SkillsDict {
        var result = EnkaDBModelsHSR.SkillsDict()
        skillTreeDB.forEach { currentSkillTree in
            let pathComponents = currentSkillTree.iconPath.split(separator: "/")
            let newComponents = pathComponents.prefix(2) + pathComponents.suffix(1)
            let assembled = EnkaDBModelsHSR.Skill(
                iconPath: newComponents.joined(separator: "/"),
                pointType: currentSkillTree.pointType
            )
            result[currentSkillTree.id.description] = assembled
        }
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_ranks.json`.
    func assembleEnkaRanks() throws -> EnkaDBModelsHSR.SkillRanksDict {
        var result = EnkaDBModelsHSR.SkillRanksDict()
        avatarRankDB.forEach { currentASR in
            let pathComponents = currentASR.iconPath.split(separator: "/")
            let newComponents = pathComponents.prefix(2) + pathComponents.suffix(1)
            let assembled = EnkaDBModelsHSR.SkillRank(
                iconPath: newComponents.joined(separator: "/"),
                skillAddLevelList: currentASR.skillAddLevelList
            )
            result[currentASR.id.description] = assembled
        }
        return result
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_skilltree.json`.
    func assembleEnkaSkillTree() throws -> EnkaDBModelsHSR.SkillTreesDict {
        var resultMap = EnkaDBModelsHSR.SkillTreesDict()
        let filteredRawDB = skillTreeDB.filter { $0.level == 1 }
        filteredRawDB.forEach { skillNodeObj in
            let pointUUID = skillNodeObj.pointID.description
            let avatarUUID = skillNodeObj.avatarID.description
            let isBaseSkill = skillNodeObj.pointName.isEmpty // If not, it's an extended skill.
            guard !isBaseSkill else {
                resultMap[skillNodeObj.avatarID.description, default: [:]]["0", default: []]
                    .append(.baseSkill(skillNodeObj.pointID.description))
                return
            }
            // Start handling.
            guard skillNodeObj.previousVertex == nil else { return }
            var currentClusterContainer: [EnkaDBModelsHSR.SkillInTree] {
                get { resultMap[avatarUUID, default: [:]]["1", default: []] }
                set { resultMap[avatarUUID, default: [:]]["1", default: []] = newValue }
            }
            if !skillNodeObj.hasMultipleNestedNextVertices {
                var newCluster: [String] = skillNodeObj.allNextVertexIDs?.map(\.description) ?? []
                newCluster.insert(pointUUID, at: 0)
                currentClusterContainer.append(.extendedSkills(newCluster))
            } else if let nestedMap = skillNodeObj.allNextVertexIDClusters {
                nestedMap.sorted {
                    $0.key < $1.key
                }.forEach { rawKey, rawIntCluster in
                    var strCluster = rawIntCluster.map(\.description)
                    strCluster.insert(rawKey.description, at: 0)
                    currentClusterContainer.append(.extendedSkills(strCluster))
                }
                currentClusterContainer.append(.extendedSkills([pointUUID]))
            }
        }
        /// Cleaning up the aftermath.
        for charID in resultMap.keys {
            var container: [EnkaDBModelsHSR.SkillInTree] {
                get { resultMap[charID, default: [:]]["1", default: []] }
                set { resultMap[charID, default: [:]]["1", default: []] = newValue }
            }
            var extracted = [String]()
            while case let .extendedSkills(lastCluster) = container.last, lastCluster.count == 1 {
                extracted.insert(contentsOf: lastCluster, at: 0)
                container = container.dropLast()
            }
            container.append(.extendedSkills(extracted))
        }
        return resultMap
    }
}

extension DimModels4HSR.DimDB4HSR {
    /// Assembling `honker_meta.json`.
    func assembleEnkaMeta() throws -> EnkaDBModelsHSR.Meta {
        .init(
            avatar: makeRawAvatarMetaDict(),
            equipment: makeRawEquipmentMetaDict(),
            equipmentSkill: makeRawEquipSkillMetaDict(),
            relic: .init(
                mainAffix: makeRelicMainAffixTable(),
                subAffix: makeRelicSubAffixTable(),
                setSkill: makeRelicSetSkillTable()
            ),
            tree: makeSkillTreeMetaDict()
        )
    }

    func makeSkillTreeMetaDict() -> EnkaDBModelsHSR.Meta.RawTreeMetaDict {
        var result = EnkaDBModelsHSR.Meta.RawTreeMetaDict()
        skillTreeDB.forEach { currentEntry in
            guard let property = currentEntry.statusAddList.first else { return }
            let pointID = currentEntry.pointID.description
            let level = currentEntry.level.description
            let assembled: [String: [String: Double]] = [
                "props": [
                    property.propertyType: property.value.value,
                ],
            ]
            result[pointID, default: [:]][level] = assembled
        }
        return result
    }

    func makeRelicMainAffixTable() -> EnkaDBModelsHSR.Meta.RawRelicDB.MainAffixTable {
        var result = EnkaDBModelsHSR.Meta.RawRelicDB.MainAffixTable()
        metaRelicMainAffixDB.forEach { currentEntry in
            let groupID = currentEntry.groupID.description
            let affixID = currentEntry.affixID.description
            let assembled = EnkaDBModelsHSR.Meta.RawRelicDB.MainAffix(
                property: currentEntry.property,
                baseValue: currentEntry.baseValue.value,
                levelAdd: currentEntry.levelAdd.value
            )
            result[groupID, default: [:]][affixID] = assembled
        }
        return result
    }

    func makeRelicSubAffixTable() -> EnkaDBModelsHSR.Meta.RawRelicDB.SubAffixTable {
        var result = EnkaDBModelsHSR.Meta.RawRelicDB.SubAffixTable()
        metaRelicSubAffixDB.forEach { currentEntry in
            let groupID = currentEntry.groupID.description
            let affixID = currentEntry.affixID.description
            let assembled = EnkaDBModelsHSR.Meta.RawRelicDB.SubAffix(
                property: currentEntry.property,
                baseValue: currentEntry.baseValue.value,
                stepValue: currentEntry.stepValue.value
            )
            result[groupID, default: [:]][affixID] = assembled
        }
        return result
    }

    func makeRelicSetSkillTable() -> EnkaDBModelsHSR.Meta.RawRelicDB.RawSetSkillMetaDict {
        var result = EnkaDBModelsHSR.Meta.RawRelicDB.RawSetSkillMetaDict()
        metaRelicSetSkillDB.forEach { currentEntry in
            let setID = currentEntry.setID.description
            let requireNum = currentEntry.requireNum.description
            if let property = currentEntry.propertyList.first {
                let assembled: [String: [String: Double]] = [
                    "props": [
                        property.titleRawValue: property.valueStorage.value,
                    ],
                ]
                result[setID, default: [:]][requireNum] = assembled
            } else {
                result[setID, default: [:]][requireNum] = ["props": [:]]
            }
        }
        return result
    }

    func makeRawEquipSkillMetaDict() -> EnkaDBModelsHSR.Meta.RawEquipSkillMetaDict {
        var result = EnkaDBModelsHSR.Meta.RawEquipSkillMetaDict()
        metaEqupSkillDB.forEach { currentEntry in
            guard let property = currentEntry.abilityProperty.first else { return }
            let skillID = currentEntry.skillID.description
            let name = property.propertyType
            let value = property.value.value
            let skillLevel = currentEntry.level.description
            result[skillID, default: [:]][skillLevel, default: [:]]["props", default: [:]] = [
                name: value,
            ]
        }
        return result
    }

    func makeRawAvatarMetaDict() -> EnkaDBModelsHSR.Meta.RawAvatarMetaDict {
        var result = EnkaDBModelsHSR.Meta.RawAvatarMetaDict()
        metaAvatarPromotionDB.forEach { currentEntry in
            let assembled = EnkaDBModelsHSR.Meta.AvatarMeta(
                hpBase: currentEntry.hpBase.value,
                hpAdd: currentEntry.hpAdd.value,
                attackBase: currentEntry.attackBase.value,
                attackAdd: currentEntry.attackAdd.value,
                defenceBase: currentEntry.defenceBase.value,
                defenceAdd: currentEntry.defenceAdd.value,
                speedBase: currentEntry.speedBase.value,
                criticalChance: currentEntry.criticalChance.value,
                criticalDamage: currentEntry.criticalDamage.value,
                baseAggro: currentEntry.baseAggro.value
            )
            let avatarUUID = currentEntry.avatarID.description
            let promotion = currentEntry.promotionGuarded.description
            result[avatarUUID, default: [:]][promotion] = assembled
        }
        return result
    }

    func makeRawEquipmentMetaDict() -> EnkaDBModelsHSR.Meta.RawEquipmentMetaDict {
        var result = EnkaDBModelsHSR.Meta.RawEquipmentMetaDict()
        metaEquipPromotionDB.forEach { currentEntry in
            let assembled = EnkaDBModelsHSR.Meta.EquipmentMeta(
                baseHP: currentEntry.baseHP.value,
                hpAdd: currentEntry.baseHPAdd.value,
                baseAttack: currentEntry.baseAttack.value,
                attackAdd: currentEntry.baseAttackAdd.value,
                baseDefence: currentEntry.baseDefence.value,
                defenceAdd: currentEntry.baseDefenceAdd.value
            )
            let equipUUID = currentEntry.equipmentID.description
            let promotion = currentEntry.promotionGuarded.description
            result[equipUUID, default: [:]][promotion] = assembled
        }
        return result
    }
}
