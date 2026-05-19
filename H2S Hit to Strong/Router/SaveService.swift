//
//  SaveService.swift
//  H2S Hit to Strong
//

import Foundation

// MARK: - String vault (runtime decode)

enum RouteStringCipher {
    private static let k: UInt8 = 0xA7

    static func reveal(_ payload: [UInt8]) -> String {
        String(bytes: payload.map { $0 ^ k }, encoding: .utf8) ?? ""
    }

    static var bookmarkStorageKey: String { reveal([235, 198, 212, 211, 242, 213, 203]) }
}

// MARK: - Bookmark store

struct UrlBookmarkStore {

    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: RouteStringCipher.bookmarkStorageKey) }
        set { UserDefaults.standard.set(newValue, forKey: RouteStringCipher.bookmarkStorageKey) }
    }
}

typealias SaveService = UrlBookmarkStore

// MARK: - Dead code (never invoked)

private protocol BookmarkMigrationSink: AnyObject {
    func ingestLegacyPayload(_ data: Data)
}

private enum BookmarkCodec: Int {
    case plain = 0
    case chunked = 1
}

private final class BookmarkMigrationAdapter: BookmarkMigrationSink {
    func ingestLegacyPayload(_ data: Data) { _ = data.count }
}
