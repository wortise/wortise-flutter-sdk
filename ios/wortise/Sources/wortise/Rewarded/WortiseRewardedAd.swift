import Flutter
import UIKit
import WortiseSDK

public class WortiseRewardedAd: NSObject, FlutterPlugin {

    public static let channelId = "\(WortiseFlutterPlugin.channelMain)/rewardedAd"


    fileprivate var binaryMessenger: FlutterBinaryMessenger

    fileprivate var instances = [String: WARewardedAd]()
    

    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let instance = WortiseRewardedAd(binaryMessenger)

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

        case "loadAd":
            loadAd(args, result: result)

        case "showAd":
            showAd(args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    fileprivate func create(instance adUnitId: String) -> WARewardedAd {
        let channelId = "\(WortiseRewardedAd.channelId)_\(adUnitId)"

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let rewardedAd = WARewardedAd(adUnitId: adUnitId)

        rewardedAd.delegate = WortiseRewardedDelegate(channel)

        instances[adUnitId] = rewardedAd

        return rewardedAd
    }

    fileprivate func destroy(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        instances.removeValue(forKey: adUnitId)?.destroy()

        result(nil)
    }

    fileprivate func isAvailable(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        let rewardedAd = instances[adUnitId]

        result(rewardedAd?.isAvailable == true)
    }

    fileprivate func isDestroyed(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        let rewardedAd = instances[adUnitId]

        result(rewardedAd?.isDestroyed == true)
    }

    fileprivate func loadAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        let rewardedAd = instances[adUnitId] ?? create(instance: adUnitId)

        rewardedAd.loadAd()

        result(nil)
    }

    fileprivate func showAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        guard let rewardedAd = instances[adUnitId], rewardedAd.isAvailable else {
            result(false)
            return
        }
        
        guard let viewController = WortiseFlutterPlugin.viewController else {
            result(false)
            return
        }

        rewardedAd.showAd(from: viewController)

        result(true)
    }
}

fileprivate class WortiseRewardedDelegate: WARewardedDelegate {

    fileprivate let channel: FlutterMethodChannel


    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func didClick(rewardedAd: WARewardedAd) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    func didComplete(rewardedAd: WARewardedAd, reward: WAReward) {
        let values: [String: Any?] = [
            "amount":  reward.amount,
            "label":   reward.label,
            "success": reward.success
        ]

        channel.invokeMethod("completed", arguments: values)
    }
    
    func didDismiss(rewardedAd: WARewardedAd) {
        channel.invokeMethod("dismissed", arguments: nil)
    }
    
    func didFailToLoad(rewardedAd: WARewardedAd, error: WAAdError) {
        channel.invokeMethod("failedToLoad", arguments: error.toMap())
    }
    
    func didFailToShow(rewardedAd: WARewardedAd, error: WAAdError) {
        channel.invokeMethod("failedToShow", arguments: error.toMap())
    }

    func didImpress(rewardedAd: WARewardedAd) {
        channel.invokeMethod("impression", arguments: nil)
    }

    func didLoad(rewardedAd: WARewardedAd) {
        channel.invokeMethod("loaded", arguments: nil)
    }

    func didPayRevenue(rewardedAd: WARewardedAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }

    func didShow(rewardedAd: WARewardedAd) {
        channel.invokeMethod("shown", arguments: nil)
    }
}
