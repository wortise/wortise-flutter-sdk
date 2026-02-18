import Flutter
import UIKit
import WortiseSDK

public class WortiseGoogleNativeAdManager: NSObject, WortiseAdWithView, FlutterPlugin {

    fileprivate static var adFactories = [String: WortiseGoogleNativeAdFactory]()


    public static let channelId = "\(WortiseFlutterPlugin.channelMain)/nativeAd"

    fileprivate(set)
    public static var instance: WortiseGoogleNativeAdManager? = nil


    fileprivate var binaryMessenger: FlutterBinaryMessenger

    fileprivate var instances = [String: WortiseGoogleNativeAd]()


    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let instance = WortiseGoogleNativeAdManager(binaryMessenger)

        registrar.addMethodCallDelegate(instance, channel: channel)

        self.instance = instance
    }

    public static func registerAdFactory(_ id: String, nativeAdFactory: WortiseGoogleNativeAdFactory) {
        adFactories[id] = nativeAdFactory
    }

    public static func unregisterAdFactory(_ id: String) {
        adFactories.removeValue(forKey: id)
    }


    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
    }

    func get(platformView adId: String) -> FlutterPlatformView? {
        guard let nativeAdView = instances[adId]?.nativeAdView else {
            return nil
        }

        return WortisePlatformView(nativeAdView)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "destroy":
            destroy(args, result: result)

        case "load":
            load(args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    fileprivate func clear(_ adId: String) {
        instances.removeValue(forKey: adId)?.destroy()
    }

    fileprivate func create(
        instance adId: String,
        adUnitId:      String,
        adFactory:     WortiseGoogleNativeAdFactory
    ) -> WortiseGoogleNativeAd {

        clear(adId)

        let nativeAd = WortiseGoogleNativeAd(
            viewIdentifier:  adId,
            adUnitId:        adUnitId,
            adFactory:       adFactory,
            binaryMessenger: binaryMessenger
        )

        instances[adId] = nativeAd

        return nativeAd
    }

    fileprivate func destroy(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adId = args?["adId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Ad ID is required", details: nil))
            return
        }

        clear(adId)

        result(nil)
    }

    fileprivate func load(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard
            let adId      = args?["adId"]      as? String,
            let adUnitId  = args?["adUnitId"]  as? String,
            let factoryId = args?["factoryId"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Required arguments are missing", details: nil))
            return
        }
        
        guard let adFactory = WortiseGoogleNativeAdManager.adFactories[factoryId] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Can't find NativeAdFactory with id: \(factoryId)", details: nil))
            return
        }

        let nativeAd = create(
            instance:  adId,
            adUnitId:  adUnitId,
            adFactory: adFactory
        )

        nativeAd.load()

        result(nil)
    }
}
