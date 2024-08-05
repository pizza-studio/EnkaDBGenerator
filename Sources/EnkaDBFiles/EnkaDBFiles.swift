// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation

public enum EnkaDBFileProvider {
    public static func getBundledJSONFileObject<T: Decodable>(
        fileNameStem: String,
        type: T.Type,
        decoderConfigurator: ((JSONDecoder) -> Void)? = nil
    )
        -> T? {
        guard let url = Bundle.module.url(
            forResource: fileNameStem, withExtension: "json"
        ) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoderConfigurator?(decoder)
        return try? decoder.decode(T.self, from: data)
    }

    public static func getBundledJSONFileData(
        fileNameStem: String
    )
        -> Data? {
        guard let url = Bundle.module.url(
            forResource: fileNameStem, withExtension: "json"
        ) else { return nil }
        return try? Data(contentsOf: url)
    }
}
