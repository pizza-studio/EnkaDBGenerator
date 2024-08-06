# EnkaDBGenerator

This repository is designed to be an alternative method to compile the same JSON files offered in Enka-API-docs repo, utilizing ExcelConfigData from Dimbreath's repos.

### Notices

> 1. This app cannot be compiled as an effective copy on Windows **virtural macine** due to how Swift Foundation **URL APIs behave buggy on virtualized** Windows platforms. Right now, the only approach to use this tool on Windows VM is to use it through WSL (Windows Sub-System for Linux). You enter into the WSL shell and install a Linux version of Swift, then you follow the following instructions to use this tool.

> 2. This repo has been torn down into individual sub-packages for other purposes serving apps developed by Pizza-Studio. For example: The `EnkaDBFiles` sub-package provides direct API for accessing its bundled specimen files, and the user can use `EnkaDBModels` to decode them. Still, this SPM is designed to focus on its main job, hence limited extra features.

### Usage

- Method 1: Use it as a Swift Package in Xcode.
- Method 2: Cross-platform usage.
  - Step 1: [Install Swift](https://www.swift.org/install/).
    - At least Swift 5.9, recommending the latest Swift stable build on non-Apple systems.
  - Step 2: Compile the package.
    - `swift build -c release`
      - `swift build -c debug` also works but the localization data are only compiled for `[ja-JP]`, `[zh-Hans]`, and `[en-US]`.
    - Built executable file path is `.build/release/EnkaDBGenerator`.
  - Step 3: Run the compiled executable to generate JSON files to the specified destination folder path.
    - You only need at least two parameters.
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

> Support for ZZZ (Zenless Zone Zero) is currently not planned due to multiple reasons.

### License

All Swift program files (but not the data structures used for decoding & encoding data) are licensed under:

```
// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.
```

$ EOF.
