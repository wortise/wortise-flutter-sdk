import Flutter
import UIKit
import WortiseSDK

public class WortiseAppOpenAd: NSObject, FlutterPlugin {

    private static let channelId = "\(WortiseFlutterPlugin.channelMain)/appOpenAd"


    private var binaryMessenger: FlutterBinaryMessenger

    private var instances = [String: WAAppOpenAd]()


    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let instance = WortiseAppOpenAd(binaryMessenger)

        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "destroy":
            destroy(args, result: result)

        case "isAvailable":
            isAvailable(args, result: result)

        case "isDestroyed":
            isDestroyed(args, result: result)

        case "isShowing":
            isShowing(args, result: result)

        case "loadAd":
            loadAd(args, result: result)

        case "showAd":
            showAd(args, result: result)

        case "tryToShowAd":
            tryToShowAd(args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    private func create(instance adUnitId: String) -> WAAppOpenAd {
        let channelId = "\(WortiseAppOpenAd.channelId)_\(adUnitId)"

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let appOpenAd = WAAppOpenAd(adUnitId: adUnitId)

        appOpenAd.delegate = WortiseAppOpenDelegate(channel)

        instances[adUnitId] = appOpenAd

        return appOpenAd
    }

    private func destroy(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        instances.removeValue(forKey: adUnitId)?.destroy()

        result(nil)
    }

    private func isAvailable(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let appOpenAd = instances[adUnitId]

        result(appOpenAd?.isAvailable == true)
    }

    private func isDestroyed(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let appOpenAd = instances[adUnitId]

        result(appOpenAd?.isDestroyed == true)
    }

    private func isShowing(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let appOpenAd = instances[adUnitId]

        result(appOpenAd?.isShowing == true)
    }

    private func loadAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let appOpenAd = instances[adUnitId] ?? create(instance: adUnitId)

        if let autoReload = args?["autoReload"] as? Bool {
            appOpenAd.autoReload = autoReload
        }

        appOpenAd.loadAd()

        result(nil)
    }

    private func showAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        guard let appOpenAd = instances[adUnitId], appOpenAd.isAvailable else {
            result(false)
            return
        }

        guard let viewController = WortiseFlutterPlugin.viewController else {
            result(false)
            return
        }

        appOpenAd.showAd(from: viewController)

        result(true)
    }

    private func tryToShowAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        guard let appOpenAd = instances[adUnitId] else {
            result(false)
            return
        }

        guard let viewController = WortiseFlutterPlugin.viewController else {
            result(false)
            return
        }

        appOpenAd.tryToShowAd(from: viewController)

        result(true)
    }
}

private class WortiseAppOpenDelegate: WAAppOpenDelegate {

    private let channel: FlutterMethodChannel


    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func didClick(appOpenAd: WAAppOpenAd) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    func didDismiss(appOpenAd: WAAppOpenAd) {
        channel.invokeMethod("dismissed", arguments: nil)
    }

    func didFailToLoad(appOpenAd: WAAppOpenAd, error: WAAdError) {
        channel.invokeMethod("failedToLoad", arguments: error.toMap())
    }

    func didFailToShow(appOpenAd: WAAppOpenAd, error: WAAdError) {
        channel.invokeMethod("failedToShow", arguments: error.toMap())
    }

    func didImpress(appOpenAd: WAAppOpenAd) {
        channel.invokeMethod("impression", arguments: nil)
    }

    func didLoad(appOpenAd: WAAppOpenAd) {
        channel.invokeMethod("loaded", arguments: nil)
    }

    func didPayRevenue(appOpenAd: WAAppOpenAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }

    func didShow(appOpenAd: WAAppOpenAd) {
        channel.invokeMethod("shown", arguments: nil)
    }
}
