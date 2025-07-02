// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - DimModelsEnumProtocol

protocol DimModelsEnumProtocol: Hashable, CaseIterable, Sendable {
    static var baseURLHeader: String { get }
    static var folderName: String { get }
    var fileNameStem: String { get }
    var hasCollabFilesToCollect: Bool { get }
}

extension DimModelsEnumProtocol {
    var jsonURL: URL {
        URL(string: Self.baseURLHeader + Self.folderName + "\(fileNameStem).json")!
    }

    var jsonURL4Collab: URL? {
        guard hasCollabFilesToCollect else { return nil }
        return URL(string: Self.baseURLHeader + Self.folderName + "\(fileNameStem)LD.json")!
    }

    func rawDataToParse(
        isCollab: Bool = false
    ) async throws
        -> Data {
        if isCollab {
            guard let jsonURL4Collab else { return .init([]) }
            print("// Fetching: \(jsonURL4Collab.absoluteString)")
            let (data, _) = try await URLSession.shared.asyncData(from: jsonURL4Collab)
            return data
        }
        print("// Fetching: \(jsonURL.absoluteString)")
        let (data, _) = try await URLSession.shared.asyncData(from: jsonURL)
        return data
    }

    /// This API does the tasks one-by-one.
    static func getDataStack1By1<T: DimModelsEnumProtocol>(
        isCollab: Bool = false
    ) async throws
        -> [T: Data] {
        var resultBuffer = [T: Data]()
        let theCases = !isCollab ? Array(T.allCases) : T.allCases.filter(\.hasCollabFilesToCollect)
        for currentCase in theCases {
            let fetched = try await currentCase.rawDataToParse(isCollab: isCollab)
            if !fetched.isEmpty {
                resultBuffer[currentCase] = fetched
            }
        }
        return resultBuffer
    }

    static func getDataStack<T: DimModelsEnumProtocol>(
        oneByOne: Bool = false,
        isCollab: Bool = false
    ) async throws
        -> [T: Data] {
        guard !oneByOne else { return try await getDataStack1By1(isCollab: isCollab) }
        return try await withThrowingTaskGroup(
            of: (tag: T, data: Data).self,
            returning: [T: Data].self
        ) { taskGroup in
            let theCases = !isCollab ? Array(T.allCases) : T.allCases.filter(\.hasCollabFilesToCollect)
            theCases.forEach { currentCase in
                taskGroup.addTask {
                    let data = try await currentCase.rawDataToParse(isCollab: isCollab)
                    return (tag: currentCase, data: data)
                }
            }
            var results = [T: Data]()
            for try await result in taskGroup {
                guard !result.data.isEmpty else { continue }
                results[result.tag] = result.data
            }
            return results
        }
    }
}
