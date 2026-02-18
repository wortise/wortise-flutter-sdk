import Flutter
import UIKit
import WortiseSDK

public class WortiseGoogleNativeAdManager: NSObject, WortiseAdWithView, FlutterPlugin {

    private static var adFactories = [String: WortiseGoogleNativeAdFactory]()


    internal static let channelId = "\(WortiseFlutterPlugin.channelMain)/googleNativeAd"


    private(set)
    public static var instance: WortiseGoogleNativeAdManager?


    private var binaryMessenger: FlutterBinaryMessenger

    private var instances = [String: WortiseGoogleNativeAd]()


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

    func get(platformView instanceId: String) -> FlutterPlatformView? {
        guard let nativeAdView = instances[instanceId]?.nativeAdView else {
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


    private func clear(_ instanceId: String) {
        instances.removeValue(forKey: instanceId)?.destroy()
    }

    private func create(
        instance id: String,
        adUnitId:    String,
        adFactory:   WortiseGoogleNativeAdFactory
    ) -> WortiseGoogleNativeAd {

        clear(id)

        let nativeAd = WortiseGoogleNativeAd(
            viewIdentifier:  id,
            adUnitId:        adUnitId,
            adFactory:       adFactory,
            binaryMessenger: binaryMessenger
        )

        instances[id] = nativeAd

        return nativeAd
    }

    private func destroy(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let instanceId = args?["instanceId"] as? String else {
            result(FlutterError.invalidArgument("Ad ID is required"))
            return
        }

        clear(instanceId)

        result(nil)
    }

    private func load(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard
            let adUnitId   = args?["adUnitId"]   as? String,
            let factoryId  = args?["factoryId"]  as? String,
            let instanceId = args?["instanceId"] as? String
        else {
            result(FlutterError.invalidArgument("Required arguments are missing"))
            return
        }

        guard let adFactory = WortiseGoogleNativeAdManager.adFactories[factoryId] else {
            result(FlutterError.invalidArgument("Can't find NativeAdFactory with id: \(factoryId)"))
            return
        }

        let nativeAd = create(
            instance:  instanceId,
            adUnitId:  adUnitId,
            adFactory: adFactory
        )

        nativeAd.load()

        result(nil)
    }
}
