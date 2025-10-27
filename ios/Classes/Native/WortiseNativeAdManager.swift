import Flutter
import UIKit
import WortiseSDK

public class WortiseNativeAdManager: NSObject, WortiseAdWithView, FlutterPlugin {

    private static var adViewFactories = [String: WortiseNativeAdViewFactory]()

    fileprivate static let channelId = "\(WortiseFlutterPlugin.channelMain)/nativeAd"


    private(set)
    public static var instance: WortiseNativeAdManager?


    private var adInstances = [String: WANativeAd]()

    private var lastAdId = 0


    fileprivate var binaryMessenger: FlutterBinaryMessenger

    fileprivate var instances = [String: WANativeAdLoader]()


    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let instance = WortiseNativeAdManager(binaryMessenger)

        registrar.addMethodCallDelegate(instance, channel: channel)

        self.instance = instance
    }

    public static func registerAdViewFactory(_ id: String, factory: WortiseNativeAdViewFactory) {
        adViewFactories[id] = factory
    }

    public static func unregisterAdViewFactory(_ id: String) {
        adViewFactories.removeValue(forKey: id)
    }


    init(_ binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
    }

    func get(platformView adId: String) -> FlutterPlatformView? {
        guard let adView = adInstances[adId]?.adView else {
            return nil
        }

        return WortisePlatformView(adView)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "destroy":
            destroy(args, result: result)

        case "destroyAd":
            destroyAd(args, result: result)

        case "isDestroyed":
            isDestroyed(args, result: result)

        case "loadAd":
            loadAd(args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    private func create(
        instance adUnitId: String,
        factory:           WortiseNativeAdViewFactory
    ) -> WANativeAdLoader {

        let delegate = WortiseNativeDelegate(self,
                                             adUnitId: adUnitId,
                                             factory:  factory)

        let loader = WANativeAdLoader(adUnitId: adUnitId, delegate: delegate)

        instances[adUnitId] = loader

        return loader
    }

    private func destroy(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        instances.removeValue(forKey: adUnitId)?.destroy()

        result(nil)
    }

    private func destroyAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adId = args?["adId"] as? String else {
            result(FlutterError.invalidArgument("Ad ID is required"))
            return
        }

        adInstances.removeValue(forKey: adId)?.destroy()

        result(nil)
    }

    private func isDestroyed(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let adUnitId = args?["adUnitId"] as? String else {
            result(FlutterError.invalidArgument("Ad unit ID is required"))
            return
        }

        let loader = instances[adUnitId]

        result(loader?.isDestroyed == true)
    }

    private func loadAd(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard
            let adUnitId  = args?["adUnitId"]  as? String,
            let factoryId = args?["factoryId"] as? String
        else {
            result(FlutterError.invalidArgument("Required arguments are missing"))
            return
        }

        guard let factory = Self.adViewFactories[factoryId] else {
            result(FlutterError.invalidArgument("Can't find WortiseNativeAdViewFactory with id: \(factoryId)"))
            return
        }

        let loader = instances[adUnitId] ?? create(instance: adUnitId, factory: factory)

        loader.loadAd()

        result(nil)
    }


    fileprivate func append(ad: WANativeAd) -> String {
        lastAdId += 1

        let adId = String(lastAdId)

        adInstances[adId] = ad

        return adId
    }
}

private class WortiseNativeDelegate: WANativeDelegate {

    private let adUnitId: String

    private let channel: FlutterMethodChannel

    private let factory: WortiseNativeAdViewFactory

    private let manager: WortiseNativeAdManager


    init(_ manager: WortiseNativeAdManager, adUnitId: String, factory: WortiseNativeAdViewFactory) {
        self.adUnitId = adUnitId
        self.factory  = factory
        self.manager  = manager

        self.channel = FlutterMethodChannel(
            name: "\(WortiseNativeAdManager.channelId)_\(adUnitId)",
            binaryMessenger: manager.binaryMessenger
        )
    }

    func didClick(nativeAd: WANativeAd) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    func didFailToLoad(nativeAd error: WAAdError) {
        channel.invokeMethod("failedToLoad", arguments: error.toMap())
    }

    func didImpress(nativeAd: WANativeAd) {
        channel.invokeMethod("impression", arguments: nil)
    }

    func didLoad(nativeAd: WANativeAd) {
        guard let loader = manager.instances[adUnitId] else {
            return
        }

        let adView = factory.createNativeAdView()

        guard loader.render(ad: nativeAd, into: adView) else {
            didFailToLoad(nativeAd: .renderError)
            return
        }

        let adId = manager.append(ad: nativeAd)

        let values = [
            "adId": adId
        ]

        channel.invokeMethod("loaded", arguments: values)
    }

    func didPayRevenue(nativeAd: WANativeAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }
}

public protocol WortiseNativeAdViewFactory {
    func createNativeAdView() -> WANativeAdView
}
