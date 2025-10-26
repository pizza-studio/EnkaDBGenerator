# EnkaDB Format Architecture Changes

This document describes the EnkaDB format architecture and recent changes to align with the [EnkaNetwork/API-docs](https://github.com/EnkaNetwork/API-docs) repository structure.

## Overview

EnkaDB provides JSON files containing game data for **Genshin Impact** and **Honkai: Star Rail** that can be used to decode and display character information from the Enka.Network API.

## Directory Structure

```
Sources/EnkaDBFiles/Resources/Specimen/
├── GI/          # Genshin Impact data files
└── HSR/         # Honkai: Star Rail data files
```

## Genshin Impact (GI) Files

### Current Files (as of this refactoring)

| Filename | Description |
|----------|-------------|
| `characters.json` | Character data including skills, constellations, costumes, and stats |
| `loc.json` | Localization strings for all supported languages |
| `namecards.json` | Name card data |
| `pfps.json` | Profile picture data |

### Target Structure (from EnkaNetwork/API-docs)

The target structure includes additional files with more comprehensive data:

| Filename | Description | Status |
|----------|-------------|--------|
| `avatars.json` | Enhanced character data with base props, curves, and promotion data | 🔄 Planned |
| `locs.json` | Localization strings (renamed from `loc.json`) | 🔄 Planned |
| `namecards.json` | Name card data | ✅ Current |
| `pfps.json` | Profile picture data | ✅ Current |
| `affixes.json` | Artifact affix efficiency data | 📋 Future |
| `curves.json` | Character and weapon growth curves | 📋 Future |
| `relic_levels.json` | Artifact level scaling data | 📋 Future |
| `relics.json` | Artifact/Relic data | 📋 Future |
| `weapons.json` | Weapon data with stats and refinements | 📋 Future |

### Key Changes

#### 1. Mannequin Characters (✅ Implemented)

**Issue**: The mannequin characters (`10000117` and `10000118`) were not being generated.

**Solution**: 
- Added support for mannequin character IDs in the `candSkillDepotIds` generator to treat them like protagonist characters with element variants
- Skips first skill depot (11701, 11801) which lacks valid elemental burst
- Starting from game version 6.1, mannequins have proper Elemental Burst skills that define their elements
- Mannequins now generate 7 element variants each (Fire, Water, Electric, Ice, Wind, Rock, Grass)

**Technical Details**:
- Depot 11701/11801 has `energySkill: 0` (no elemental burst)
- Depots 11702-11708 have energy skills 111751-111757 (Fire through Grass elements)
- Depots 11802-11808 have energy skills 111851-111857 (Fire through Grass elements)
- Element is correctly derived from the `costElemType` field of each energy skill

**Character IDs Generated**:
- `10000117-11702` through `10000117-11708` (Male mannequin, 7 elements)
- `10000118-11802` through `10000118-11808` (Female mannequin, 7 elements)

#### 2. Icon Path Format

**Current Format**: Icon names without path prefixes
```json
{
  "Skills": {
    "10024": "Skill_A_01",
    "10018": "Skill_S_Ayaka_01"
  }
}
```

**Target Format**: Full paths with `/ui/` prefix
```json
{
  "Skills": {
    "10024": "/ui/Skill_A_01.png",
    "10018": "/ui/Skill_S_Ayaka_01.png"
  }
}
```

**Status**: 🔄 Planned - Requires updates to assembler logic

#### 3. Additional Character Fields

The target `avatars.json` includes additional fields not currently generated:

- `BaseProps`: Base properties at level 1 (HP, ATK, DEF, Crit Rate, Crit Damage, etc.)
- `PropGrowCurves`: Growth curve IDs for scaling properties
- `PromoteProps`: Property bonuses at each ascension level

**Example**:
```json
{
  "10000002": {
    "BaseProps": {
      "1": 1000.986,  // HP
      "4": 26.6266,   // ATK
      "7": 61.0266,   // DEF
      "20": 0.05,     // Crit Rate
      "22": 0.5,      // Crit Damage
      "28": 0         // Energy Recharge
    },
    "PropGrowCurves": {
      "1": 105,       // HP curve
      "4": 205,       // ATK curve
      "7": 105        // DEF curve
    },
    "PromoteProps": [
      { ... }         // Array of promotion level bonuses
    ]
  }
}
```

**Status**: 📋 Future - Requires fetching and parsing additional Dimbreath data files

## Honkai: Star Rail (HSR) Files

### Current Files (Legacy `honker_*` format)

| Filename | Description |
|----------|-------------|
| `honker_avatars.json` | Profile avatar icons |
| `honker_characters.json` | Basic character data |
| `honker_meta.json` | Metadata including skill data |
| `honker_ranks.json` | Eidolon (constellation) data |
| `honker_relics.json` | Relic set data |
| `honker_skills.json` | Skill descriptions |
| `honker_skilltree.json` | Skill tree advancement data |
| `honker_weps.json` | Light cone (weapon) data |
| `hsr.json` | Localization strings |

### Target Structure

The `honker_*` files are **deprecated** but maintained for backward compatibility. New files without the prefix provide enhanced data:

| Filename | Description | Status |
|----------|-------------|--------|
| `avatars.json` | Comprehensive character data with skins, skill trees, and promotion stats | 🔄 Planned |
| `weapons.json` | Enhanced light cone data with promotion curves | 🔄 Planned |
| `ranks.json` | Eidolon data with skill upgrades | 🔄 Planned |
| `skills.json` | Detailed skill information | 🔄 Planned |
| `tree.json` | Complete skill tree data | 🔄 Planned |
| `relics.json` | Comprehensive relic data | 🔄 Planned |
| `affixes.json` | Relic affix efficiency data | 🔄 Planned |
| `pfps.json` | Profile picture icons | 🔄 Planned |
| `hsr.json` | Localization strings (kept) | ✅ Current |
| `honker_*` | Legacy files (deprecated but kept) | ✅ Current |

### Key Differences: New vs Legacy Format

The new files include significantly more data:

1. **avatars.json vs honker_characters.json**:
   - Adds `Skins` data for alternate character appearances
   - Includes complete `SkillTree` with advancement paths
   - Contains `Promotion` data with stat values at each level

2. **weapons.json vs honker_weps.json**:
   - Includes full `Promotion` data with stat scaling
   - More detailed refinement information

3. **Icon Paths**: New files use full paths with `/ui/hsr/` prefix

## Data Sources

All data is fetched from the following repositories:

- **Genshin Impact**: [DimbreathBot/AnimeGameData](https://github.com/DimbreathBot/AnimeGameData)
- **Honkai: Star Rail**: [DimbreathBot/TurnBasedGameData](https://github.com/DimbreathBot/TurnBasedGameData)

These repositories contain game data files extracted from the official game clients.

## Implementation Status

### Completed ✅
- ✅ Mannequin character support (10000117, 10000118)
- ✅ Seven element variants for mannequins
- ✅ Legacy honker_* file generation for HSR

### In Progress 🔄
- 🔄 File naming alignment (characters.json → avatars.json, loc.json → locs.json)
- 🔄 Icon path prefix updates
- 🔄 New HSR file generation (avatars.json, weapons.json, etc.)

### Planned 📋
- 📋 GI: Additional avatar fields (BaseProps, PropGrowCurves, PromoteProps)
- 📋 GI: New files (affixes.json, curves.json, relic_levels.json, relics.json, weapons.json)
- 📋 HSR: Enhanced data in new format files
- 📋 Full parity with EnkaNetwork/API-docs structure

## Development Notes

### Adding New Data Fields

To add new fields to the generated JSON:

1. **Update Models** in `Sources/EnkaDBModels/`
   - Add new properties to the model structs
   - Ensure `Codable` conformance with proper `CodingKeys`

2. **Fetch Source Data** in `Sources/EnkaDBGeneratorModule/DimbreathModels/`
   - Add new enum case to `DimModels4GI` or `DimModels4HSR`
   - Create corresponding data structure
   - Update data fetching in init methods

3. **Assemble Data** in `Sources/EnkaDBGeneratorModule/DimbreathModels/DimDBImpls_Assembler/`
   - Update assembler functions to populate new fields
   - Transform Dimbreath data format to EnkaDB format

4. **Test** by generating specimen files and comparing with target

### Special Character Handling

Some characters require special logic:

- **Protagonists (Traveler)**: Have multiple element variants via `candSkillDepotIds`
- **Mannequins**: Test characters with element variants but no elemental burst skills
- **Collab Characters** (HSR): Fetched from separate collab data files

## API Compatibility

The EnkaDB files are designed to work with the Enka.Network API responses:

- **GI**: `https://enka.network/api/uid/{uid}`
- **HSR**: `https://enka.network/api/hsr/uid/{uid}`

The JSON files provide the metadata needed to decode character IDs, skill IDs, artifact IDs, etc. from the API responses.

## Contributing

When adding new features or fixing bugs:

1. Ensure backward compatibility with existing consumers
2. Update this documentation
3. Add tests for new data fields
4. Verify output against EnkaNetwork/API-docs reference files

## License

This project follows the licensing as defined in the main README.md file.
