// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License).
// ====================
// This code is released under the AGPL v3.0 License (SPDX-License-Identifier: AGPL-3.0)

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - DimModelsEnumProtocol

protocol DimModelsEnumProtocol: Hashable, CaseIterable {
    static var baseURLHeader: String { get }
    static var folderName: String { get }
    var fileNameStem: String { get }
}

extension DimModelsEnumProtocol {
    var jsonFileName: String {
        "\(fileNameStem).json"
    }

    var jsonURL: URL {
        URL(string: Self.baseURLHeader + Self.folderName + jsonFileName)!
    }

    func rawDataToParse() async throws -> Data {
        #if DEBUG
        print("// Fetching: \(jsonURL.absoluteString)")
        #endif
        let (data, _) = try await URLSession.shared.asyncData(from: jsonURL)
        return data
    }

    static func getDataStack<T: DimModelsEnumProtocol>() async throws -> [T: Data] {
        try await withThrowingTaskGroup(
            of: (tag: T, data: Data).self,
            returning: [T: Data].self
        ) { taskGroup in
            T.allCases.forEach { currentCase in
                taskGroup.addTask {
                    let data = try await currentCase.rawDataToParse()
                    return (tag: currentCase, data: data)
                }
            }
            var results = [T: Data]()
            for try await result in taskGroup {
                results[result.tag] = result.data
            }
            return results
        }
    }
}