# EnkaDBGenerator

This repository is designed to be an alternative method to compile the same JSON files offered in Enka-API-docs repo, utilizing ExcelConfigData from Dimbreath's repos.

### Notice to Windows users:

- This app cannot be compiled as an effective copy on Windows due to how Swift Foundation URL APIs behave buggy on Windows. Right now, the only approach to use this tool on Windows is to use it through WSL (Windows Sub-System for Linux). You enter into the WSL shell and install a Linux version of Swift, then you follow the following instructions to use this tool.

### Usage: 

- Method 1: Use it as a Swift Package in Xcode.
- Method 2: Cross-platform usage.
  - Step 1: Install Swift.
  - Step 2: Compile the package.
    - `swift build -c release`
    - Built executable file path is `.build/release/EnkaDBGenerator`.
  - Step 3: Run the compiled executable and pipeline the output contents into a new JSON file.
    - You only need two parameters.
      - The first parameter is to specify whether it writes for Genshin or HSR.
      - The second parameter is the output folder where the generated JSON files are gonna write to.
    - Examples:
      - Genshin Impact: `./EnkaDBGenerator -GI ./OUTPUT-FOLDER`.
      - Star Rail: `./EnkaDBGenerator -HSR ./OUTPUT-FOLDER`

### Supported Games:

- Genshin Impact.
- Star Rail.

> Support for ZZZ (Zenless Zone Zero) is currently not planned regardless Dimbreath has made its ExcelConfigData repository (ZenlessData) available to the public. It's just too hard for me to figure out how to spot and organize intels needed to summarize GachaMetaDB from ZenlessData repo. Voluntary PRs are welcomed as long as you keep the generated JSON file structure consistent with existing ones for Genshin and StarRail, regardless the scripting language you familiar with (e.g. Python, etc.).

$ EOF.
