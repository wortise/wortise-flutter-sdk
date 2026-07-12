import Flutter
import UIKit
import WortiseSDK

public class WortiseInterstitialAd: NSObject, FlutterPlugin {

    public static let channelId = "\(WortiseFlutterPlugin.channelMain)/interstitialAd"


    fileprivate var binaryMessenger: FlutterBinaryMessenger

    fileprivate var instances = [String: WAInterstitialAd]()
    

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


    fileprivate func create(instance adUnitId: String) -> WAInterstitialAd {
        let channelId = "\(WortiseInterstitialAd.channelId)_\(adUnitId)"

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let interstitialAd = WAInterstitialAd(adUnitId: adUnitId)

        interstitialAd.delegate = WortiseInterstitialDelegate(channel) 

        instances[adUnitId] = interstitialAd

        return interstitialAd
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

        let interstitialAd = instances[adUnitId]

        result(interstitialAd?.isAvailable == true)
    }

    fileprivate func isDestroyed(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        let interstitialAd = instances[adUnitId]

        result(interstitialAd?.isDestroyed == true)
    }

    fileprivate func loadAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
            return
        }

        let interstitialAd = instances[adUnitId] ?? create(instance: adUnitId)

        interstitialAd.loadAd()

        result(nil)
    }

    fileprivate func showAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad unit ID is required", details: nil))
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
}

fileprivate class WortiseInterstitialDelegate: WAInterstitialDelegate {

    fileprivate let channel: FlutterMethodChannel


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

    func didShow(interstitialAd: WAInterstitialAd) {
        channel.invokeMethod("shown", arguments: nil)
    }
}
