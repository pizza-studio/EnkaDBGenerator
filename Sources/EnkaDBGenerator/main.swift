// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBGeneratorModule
import Foundation
#if canImport(WinSDK) || (!canImport(AppKit) && !canImport(UIKit) && !canImport(Glibc))
let useOneByOne = true
#else
let useOneByOne = false
#endif

var cmdArgs = Array(CommandLine.arguments.dropFirst(1))

// Parse optional named arguments.
var localPath: String?
if let idx = cmdArgs.firstIndex(of: "-localPath"), idx + 1 < cmdArgs.count {
    localPath = cmdArgs[idx + 1]
    cmdArgs.removeSubrange(idx ... idx + 1)
}

switch cmdArgs.count {
case 2, 3:
    guard let arg1st = cmdArgs.first,
          let argLast = cmdArgs.last,
          let game = EnkaDBGenerator.SupportedGame(arg: arg1st)
    else {
        print(argumentTextTutorial)
        preconditionFailure(argumentTextTutorial)
    }
    let url = URL(fileURLWithPath: argLast)
    if useOneByOne {
        print("// =========================")
        print("// Windows platform detected, will handle tasks one-by-one in lieu of Swift taskGroups.")
        print("// -------------------------")
        print(argumentTextTutorial)
    }

    if cmdArgs.count == 3,
       let arg3rd = cmdArgs.dropFirst().first,
       arg3rd.lowercased() == "-tiny" {
        EnkaDBGenerator.Config.generateCondensedJSONFiles = true
        print("// =========================")
        print("// `-tiny` argument retrieved, will generate minified JSON files instead.")
        print("// -------------------------")
    }

    if let localPath {
        print("// =========================")
        print("// Using local data path: \(localPath)")
        print("// -------------------------")
    }

    do {
        try await EnkaDBGenerator.compileEnkaDB(
            for: game, targeting: url, oneByOne: useOneByOne, localPath: localPath
        )
    } catch {
        print(error.localizedDescription)
        throw (error)
    }
default:
    print(argumentTextTutorial)
    preconditionFailure(argumentTextTutorial)
}

private let argumentTextTutorial = """
// ========================="
|| Wrong arguments. Please provide the arguments as follows:
|| 1. The 1st argument allowed: `-GI` for Genshin Impact; `-HSR` or `-SR` for Star Rail.
|| 2. The 2nd argument is optional: `-tiny`, this is to minify the generated JSON files.
|| 3. Optional: `-localPath /path/to/AnimeGameData` to use local data instead of fetching online.
|| 4. The final argument is the target directory path.
// ========================="
"""
