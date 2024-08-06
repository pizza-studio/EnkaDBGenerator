# EnkaDBGenerator

This repository is designed to be an alternative method to compile the same JSON files offered in Enka-API-docs repo, utilizing ExcelConfigData from Dimbreath's repos.

All Swift program files (but not the data structures used for decoding & encoding data) are licensed under:

```
// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.
```

### Notices

> 1. This app cannot be compiled as an effective copy on Windows **virtural macine** due to how Swift Foundation URL APIs behave buggy on Windows. Right now, the only approach to use this tool on Windows is to use it through WSL (Windows Sub-System for Linux). You enter into the WSL shell and install a Linux version of Swift, then you follow the following instructions to use this tool.

> 2. This repo has been torn down into individual sub-packages for other purposes serving apps developed by Pizza-Studio. For example: The `EnkaDBFiles` sub-package provides direct API for accessing its bundled specimen files, and the user can use `EnkaDBModels` to decode them. Still, this SPM is designed to focus on its main job, hence limited extra features.

### Usage

- Method 1: Use it as a Swift Package in Xcode.
- Method 2: Cross-platform usage.
  - Step 1: [Install Swift](https://www.swift.org/install/).
    - At least Swift 5.9, recommending the latest Swift stable build on non-Apple systems.
  - Step 2: Compile the package.
    - `swift build -c release`
    - Built executable file path is `.build/release/EnkaDBGenerator`.
  - Step 3: Run the compiled executable and pipeline the output contents into a new JSON file.
    - You only need at leasttwo parameters.
      - The first parameter is to specify whether it writes for Genshin or HSR.
      - The second argument is optional: `-tiny`, this is to minify the generated JSON files.
      - The final parameter is the output folder where the generated JSON files are gonna write to.
    - Examples:
      - Genshin Impact (pretty-printed): `./EnkaDBGenerator -GI ./OUTPUT-FOLDER`.
      - Genshin Impact (minified): `./EnkaDBGenerator -GI -tiny ./OUTPUT-FOLDER`.
      - Star Rail (pretty-printed): `./EnkaDBGenerator -HSR ./OUTPUT-FOLDER`
      - Star Rail (minified): `./EnkaDBGenerator -HSR -tiny ./OUTPUT-FOLDER`

### Supported Games

- Genshin Impact.
- Star Rail.

> Support for ZZZ (Zenless Zone Zero) is currently not planned regardless Dimbreath has made its ExcelConfigData repository (ZenlessData) available to the public. It's just too hard for me to figure out how to spot and organize intels needed to summarize GachaMetaDB from ZenlessData repo. Voluntary PRs are welcomed as long as you keep the generated JSON file structure consistent with existing ones for Genshin and StarRail, regardless the scripting language you familiar with (e.g. Python, etc.).

$ EOF.
