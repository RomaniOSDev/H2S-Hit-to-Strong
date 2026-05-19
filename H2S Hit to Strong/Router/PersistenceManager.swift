//
//  PersistenceManager.swift
//  H2S Hit to Strong
//

import Foundation

extension RouteStringCipher {
    static var nativeShellFlagKey: String {
        reveal([239, 198, 212, 244, 207, 200, 208, 201, 228, 200, 201, 211, 194, 201, 211, 241, 206, 194, 208])
    }
    static var remoteLoadFlagKey: String {
        reveal([239, 198, 212, 244, 210, 196, 196, 194, 212, 212, 193, 210, 203, 240, 194, 197, 241, 206, 194, 208, 235, 200, 198, 195])
    }
}

class SessionStateVault {
    static let shared = SessionStateVault()

    private var bookmarkKey: String { RouteStringCipher.bookmarkStorageKey }
    private var nativeShellKey: String { RouteStringCipher.nativeShellFlagKey }
    private var remoteLoadKey: String { RouteStringCipher.remoteLoadFlagKey }

    var savedUrl: String? {
        get {
            if let url = UrlBookmarkStore.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: bookmarkKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: bookmarkKey)
                if let url = URL(string: urlString) {
                    UrlBookmarkStore.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: bookmarkKey)
                UrlBookmarkStore.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get { UserDefaults.standard.bool(forKey: nativeShellKey) }
        set { UserDefaults.standard.set(newValue, forKey: nativeShellKey) }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get { UserDefaults.standard.bool(forKey: remoteLoadKey) }
        set { UserDefaults.standard.set(newValue, forKey: remoteLoadKey) }
    }

    private init() {}
}

// Legacy typealias for any stale references in templates
typealias PersistenceManager = SessionStateVault

// MARK: - Dead code

private protocol VaultSnapshotExporter {
    func exportSnapshot() -> [String: Any]
}

private enum VaultCompactionPolicy {
    case eager
    case lazy
}

private final class VaultSnapshotRecorder: VaultSnapshotExporter {
    func exportSnapshot() -> [String: Any] { [:] }
}
