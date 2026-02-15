// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(WinSDK) || (!canImport(AppKit) && !canImport(UIKit) && !canImport(Glibc))
let isWindows = true
#else
let isWindows = false
#endif

/// An extension that provides async support for fetching a URL
///
/// Needed because the Linux version of Swift does not support async URLSession yet.
extension URLSession {
    public enum AsyncError: Error {
        case invalidUrlResponse, missingResponseData
    }

    #if canImport(FoundationNetworking)

    // MARK: - Linux: Manual redirect handling to avoid FoundationNetworking crash.

    //
    // Swift's FoundationNetworking uses `try!` in `EasyHandle.configureEasyHandle(for:body:)`
    // which can crash with libcurl error 43 (CURLE_BAD_FUNCTION_ARGUMENT) when following
    // HTTP redirects. This delegate prevents automatic redirect following so we can
    // handle redirects manually without triggering that code path.

    /// A delegate that prevents URLSession from automatically following redirects.
    private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
        static let shared = NoRedirectDelegate()

        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            willPerformHTTPRedirection response: HTTPURLResponse,
            newRequest request: URLRequest,
            completionHandler: @escaping (URLRequest?) -> Void
        ) {
            completionHandler(nil)
        }
    }

    private static let noRedirectSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        return URLSession(
            configuration: config,
            delegate: NoRedirectDelegate.shared,
            delegateQueue: nil
        )
    }()

    /// Perform a single data task without following redirects.
    private func rawDataTask(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = Self.noRedirectSession.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response else {
                    continuation.resume(throwing: AsyncError.invalidUrlResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: AsyncError.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    /// Async data fetch with manual redirect following (Linux).
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: Data and response.
    public func asyncData(from url: URL) async throws -> (Data, URLResponse) {
        var currentURL = url
        for _ in 0 ..< 10 {
            let (data, response) = try await rawDataTask(from: currentURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (300 ... 399).contains(httpResponse.statusCode),
                  let location = httpResponse.value(forHTTPHeaderField: "Location"),
                  let redirectURL = URL(string: location, relativeTo: currentURL)
            else {
                return (data, response)
            }
            currentURL = redirectURL.absoluteURL
        }
        throw URLError(.httpTooManyRedirects)
    }

    #else

    /// A reimplementation of `URLSession.shared.asyncData(from: url)` required for Linux
    ///
    /// ref: https://gist.github.com/aronbudinszky/66cdb71d734ae48a2609c7f2c094a02d
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: Data and response.
    ///
    /// - Usage:
    ///
    ///     let (data, response) = try await URLSession.shared.asyncData(from: url)
    public func asyncData(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: AsyncError.invalidUrlResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: AsyncError.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    #endif
}

// MARK: - Internal Swift Extensions

extension Array where Element: Identifiable {
    subscript(wrapping index: Element.ID) -> [Element] {
        filter { $0.id == index }
    }
}

// MARK: - Decoding Strategy for Decoding UpperCamelCases

extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromPascalCase: Self {
        .custom { keys in
            PascalCaseKey(stringValue: keys.last!.stringValue)
        }
    }
}

// MARK: - PascalCaseKey

struct PascalCaseKey: CodingKey {
    // MARK: Lifecycle

    init(stringValue str: String) {
        let allCapicalized = str.filter(\.isLowercase).isEmpty
        guard !allCapicalized else {
            self.stringValue = str.lowercased()
            self.intValue = nil
            return
        }
        var count = 0
        perCharCheck: for char in str {
            if char.isUppercase {
                count += 1
            } else {
                break perCharCheck
            }
        }
        if count > 1 {
            count -= 1
        }
        self.stringValue = str.prefix(count).lowercased() + str.dropFirst(count)
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

    // MARK: Internal

    let stringValue: String
    let intValue: Int?
}
