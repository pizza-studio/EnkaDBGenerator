// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import EnkaDBGeneratorModule
import Foundation

let cmdParameters = CommandLine.arguments.dropFirst(1)

switch cmdParameters.count {
case 2:
    guard let firstArgument = cmdParameters.first,
          let secondArgument = cmdParameters.dropFirst().first,
          let game = EnkaDBGenerator.SupportedGame(arg: firstArgument)
    else {
        let errText = "!! Please give only one argument among `-GI`, `-HSR`."
        print("{\"errMsg\": \"\(errText)\"}\n")
        assertionFailure(errText)
        exit(1)
    }
    let url = URL(fileURLWithPath: secondArgument)
    do {
        try await EnkaDBGenerator.compileEnkaDB(for: game, targeting: url)
    } catch {
        print(error.localizedDescription)
        throw (error)
    }
default:
    let errText = "!! Wrong number of arguments. Please give only one argument among `-GI`, `-HSR`."
    print(errText)
    assertionFailure(errText)
    exit(1)
}
