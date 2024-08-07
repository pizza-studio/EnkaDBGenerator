// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - EnkaDBGenerator.EDBGError

extension EnkaDBGenerator {
    public enum EDBGError: Error {
        case assemblerError(msg: String)
        case fileWritingAccessError(msg: String)
    }
}

// MARK: - EnkaDBGenerator.EDBGError + LocalizedError

extension EnkaDBGenerator.EDBGError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case let .assemblerError(msg): return "[Assembler Error] " + msg
        case let .fileWritingAccessError(msg): return "[I/O Error] " + msg
        }
    }

    public var errorDescription: String? { localizedDescription }
}
