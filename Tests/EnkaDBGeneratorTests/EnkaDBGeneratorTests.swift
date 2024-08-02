// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

@testable import EnkaDBGeneratorModule
import Foundation
import XCTest

final class EnkaDBGeneratorTests: XCTestCase {
    func testInitializingDimDB4GI() async throws {
        let jsonGI = try await DimModels4GI.DimDB4GI(withLang: true)
        if let lumine = jsonGI.avatarDB.first(where: { $0.id == 10000007 }) {
            let text = jsonGI.langTable["ja-jp"]?[lumine.nameTextMapHash.description]
            XCTAssertNotNil(text)
            XCTAssertEqual(text, "蛍")
        } else {
            assertionFailure("Lumine is missing.")
        }
        let compiledMap = jsonGI.assembleEnkaLangMap()
        XCTAssertNotNil(compiledMap["uk"]?["level"])
    }
}
