// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

@testable import EnkaDBFiles
@testable import EnkaDBGeneratorModule
import Foundation
import XCTest

final class EnkaDBFilesTests: XCTestCase {
    func testBundledFileAccess() async throws {
        let obj = EnkaDBFileProvider.getBundledJSONFileObject(
            fileNameStem: "namecards", type: EnkaDBModelsGI.NameCardDict.self
        ) { decoder in
            decoder.keyDecodingStrategy = .useDefaultKeys
        }
        XCTAssertNotNil(obj)
        if let obj { print(obj) }
    }
}
