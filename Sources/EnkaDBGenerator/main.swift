// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import EnkaDBGeneratorModule
import Foundation
#if canImport(WinSDK) || (!canImport(AppKit) && !canImport(UIKit) && !canImport(Glibc))
let useOneByOne = true
#else
let useOneByOne = false
#endif

let cmdParameters = CommandLine.arguments.dropFirst(1)

switch cmdParameters.count {
case 2, 3:
    guard let arg1st = cmdParameters.first,
          let argLast = cmdParameters.last,
          let game = EnkaDBGenerator.SupportedGame(arg: arg1st)
    else {
        print(argumentTextTutorial)
        assertionFailure(argumentTextTutorial)
        exit(1)
    }
    let url = URL(fileURLWithPath: argLast)
    if useOneByOne {
        print("// =========================")
        print("// Windows platform detected, will handle tasks one-by-one in lieu of Swift taskGroups.")
        print("// -------------------------")
        print(argumentTextTutorial)
    }

    if cmdParameters.count == 3,
       let arg3rd = cmdParameters.dropFirst().first,
       arg3rd.lowercased() == "-tiny" {
        EnkaDBGenerator.Config.generateCondensedJSONFiles = true
        print("// =========================")
        print("// `-tiny` argument retrieced, will generate minified JSON files instead.")
        print("// -------------------------")
    }

    do {
        try await EnkaDBGenerator.compileEnkaDB(for: game, targeting: url, oneByOne: useOneByOne)
    } catch {
        print(error.localizedDescription)
        throw (error)
    }
default:
    print(argumentTextTutorial)
    assertionFailure(argumentTextTutorial)
    exit(1)
}

private let argumentTextTutorial = """
// ========================="
|| Wrong arguments. Please provide the arguments as follows:
|| 1. The 1st argument allowed: `-GI` for Genshin Impact; `-HSR` or `-SR` for Star Rail.
|| 2. The 2nd argument is optional: `-tiny`, this is to minify the generated JSON files.
|| 3. The final argument is the target directory path.
// ========================="
"""
