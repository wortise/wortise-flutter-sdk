import Flutter
import UIKit
import WortiseSDK

public class WortiseInterstitialAd: NSObject, FlutterPlugin {

    private static let channelId = "\(WortiseFlutterPlugin.channelMain)/interstitialAd"


    private var binaryMessenger: FlutterBinaryMessenger

    private var delegates = [String: WortiseInterstitialDelegate]()

    private var instances = [String: WAInterstitialAd]()

    private var preloadDelegates = [String: WortisePreloadDelegate]()


    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let instance = WortiseInterstitialAd(binaryMessenger)

        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "cooldownRemainingMs":
            cooldownRemainingMs(args, result: result)

        case "destroy":
            destroy(args, result: result)

        case "destroyAllPreloads":
            destroyAllPreloads(result: result)

        case "destroyPreload":
            destroyPreload(args, result: result)

        case "getNumAdsAvailable":
            getNumAdsAvailable(args, result: result)

        case "isAvailable":
            isAvailable(args, result: result)

        case "isDestroyed":
            isDestroyed(args, result: result)

        case "isInCooldown":
            isInCooldown(args, result: result)

        case "isShowing":
            isShowing(args, result: result)

        case "loadAd":
            loadAd(args, result: result)

        case "pollAd":
            pollAd(args, result: result)

        case "reloadAd":
            reloadAd(args, result: result)

        case "showAd":
            showAd(args, result: result)

        case "startPreload":
            startPreload(args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    private func cooldownRemainingMs(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId]

        result(Int((interstitialAd?.cooldownRemaining ?? 0) * 1000))
    }

    private func create(instance adUnitId: String) -> WAInterstitialAd {
        let channelId = "\(WortiseInterstitialAd.channelId)_\(adUnitId)"

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let interstitialAd = WAInterstitialAd(adUnitId: adUnitId)

        let delegate            = WortiseInterstitialDelegate(channel)

        interstitialAd.delegate = delegate

        delegates[adUnitId] = delegate
        instances[adUnitId] = interstitialAd
        

        return interstitialAd
    }

    private func destroy(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        delegates.removeValue(forKey: adUnitId)
        instances.removeValue(forKey: adUnitId)?.destroy()
        

        result(nil)
    }

    private func destroyAllPreloads(result: @escaping FlutterResult) {
        WAInterstitialAdPreloader.destroyAll()

        preloadDelegates.removeAll()

        result(nil)
    }

    private func destroyPreload(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        preloadDelegates.removeValue(forKey: adUnitId)

        result(WAInterstitialAdPreloader.destroy(adUnitId: adUnitId))
    }

    private func getNumAdsAvailable(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        result(WAInterstitialAdPreloader.numAdsAvailable(adUnitId: adUnitId))
    }

    private func isAvailable(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId]

        result(interstitialAd?.isAvailable == true)
    }

    private func isDestroyed(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId]

        result(interstitialAd?.isDestroyed == true)
    }

    private func isInCooldown(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId]

        result(interstitialAd?.isInCooldown == true)
    }

    private func isShowing(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId]

        result(interstitialAd?.isShowing == true)
    }

    private func loadAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId] ?? create(instance: adUnitId)

        if let autoRefresh = args?["autoRefresh"] as? Bool {
            interstitialAd.autoRefresh = autoRefresh
        }

        let parameters = WARequestParameters.from(args)

        interstitialAd.loadAd(parameters: parameters)

        result(nil)
    }

    private func pollAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        guard let interstitialAd = WAInterstitialAdPreloader.pollAd(adUnitId: adUnitId) else {
            result(false)
            return
        }

        instances.removeValue(forKey: adUnitId)?.destroy()

        let channelId = "\(WortiseInterstitialAd.channelId)_\(adUnitId)"

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let delegate = WortiseInterstitialDelegate(channel)

        interstitialAd.delegate = delegate

        delegates[adUnitId] = delegate
        instances[adUnitId] = interstitialAd

        result(true)
    }

    private func reloadAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let interstitialAd = instances[adUnitId] ?? create(instance: adUnitId)

        if let autoRefresh = args?["autoRefresh"] as? Bool {
            interstitialAd.autoRefresh = autoRefresh
        }

        let parameters = WARequestParameters.from(args)

        interstitialAd.reloadAd(parameters: parameters)

        result(nil)
    }

    private func showAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        guard let interstitialAd = instances[adUnitId], interstitialAd.isAvailable else {
            result(false)
            return
        }

        guard let viewController = WortiseFlutterPlugin.viewController else {
            result(false)
            return
        }

        interstitialAd.showAd(from: viewController)

        result(true)
    }

    private func startPreload(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let channelId = "\(WortiseInterstitialAd.channelId)Preloader_\(adUnitId)"

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let delegate = WortisePreloadDelegate(channel)

        let started = WAInterstitialAdPreloader.start(
            adUnitId:      adUnitId,
            configuration: WAPreloadConfiguration.from(args),
            delegate:      delegate
        )

        if started {
            preloadDelegates[adUnitId] = delegate
        }

        result(started)
    }
}

private class WortiseInterstitialDelegate: WAInterstitialDelegate {

    private let channel: FlutterMethodChannel


    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func didClick(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    func didDismiss(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("dismissed", arguments: nil)
    }

    func didFailToLoad(interstitialAd: WAInterstitialAd, error: WAAdError) {
        channel.invokeMethod("failedToLoad", arguments: error.toMap())
    }

    func didFailToShow(interstitialAd: WAInterstitialAd, error: WAAdError) {
        channel.invokeMethod("failedToShow", arguments: error.toMap())
    }

    func didImpress(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("impression", arguments: nil)
    }

    func didLoad(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("loaded", arguments: nil)
    }

    func didPayRevenue(interstitialAd: WAInterstitialAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }

    func didRefresh(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("refreshed", arguments: nil)
    }

    func didShow(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("shown", arguments: nil)
    }
}
