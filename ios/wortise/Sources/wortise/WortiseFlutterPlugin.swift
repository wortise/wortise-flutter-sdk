import Flutter
import UIKit
import WortiseSDK

public class WortiseFlutterPlugin: NSObject, FlutterPlugin {

    public static let channelMain = "wortise"

    public static var viewController: FlutterViewController? {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            return find(flutterViewController: rootViewController)
        }

        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap    { $0.windows }

        let keyWindow = windows.first(where: { $0.isKeyWindow }) ?? windows.first

        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }

        return find(flutterViewController: rootViewController)
    }


    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelMain, binaryMessenger: binaryMessenger)

        let instance = WortiseFlutterPlugin()

        registrar.addMethodCallDelegate(instance, channel: channel)

        WortiseAdSettings           .register(with: registrar)
        WortiseAppLifecycleManager  .register(with: registrar)
        WortiseAppOpenAd            .register(with: registrar)
        WortiseConsentManager       .register(with: registrar)
        WortiseDataManager          .register(with: registrar)
        WortiseGoogleNativeAdManager.register(with: registrar)
        WortiseInterstitialAd       .register(with: registrar)
        WortiseRewardedAd           .register(with: registrar)

        let adWidgetFactory = WortiseAdWidgetFactory(instance)

        registrar.register(adWidgetFactory, withId: WortiseAdWidgetFactory.channelId)

        let bannerFactory = WortiseBannerAdViewFactory(messenger: binaryMessenger)

        registrar.register(bannerFactory, withId: WortiseBannerAdViewFactory.channelId)
    }


    public func get(platformView adId: String) -> FlutterPlatformView? {
        let instances: [WortiseAdWithView?] = [
            WortiseGoogleNativeAdManager.instance
        ]

        return instances.compactMap { $0?.get(platformView: adId) }.first
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getVersion":
            result(WortiseAds.shared.version)

        case "initialize":
            initialize(call, result: result)

        case "isInitialized":
            result(WortiseAds.shared.isInitialized)

        case "isReady":
            result(WortiseAds.shared.isReady)

        case "wait":
            wait(result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    fileprivate static func find(flutterViewController vc: UIViewController) -> FlutterViewController? {
        if let flutterViewController = vc as? FlutterViewController {
            return flutterViewController
        }

        if let presented = vc.presentedViewController {
            return find(flutterViewController: presented)
        }

        if let navigation = vc as? UINavigationController, let top = navigation.topViewController {
            return find(flutterViewController: top)
        }

        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return find(flutterViewController: selected)
        }

        return nil
    }

    fileprivate func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        guard let assetKey = args["assetKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Asset key is required", details: nil))
            return
        }

        WortiseAds.shared.initialize(assetKey: assetKey) {
            result(nil)
        }
    }

    fileprivate func wait(_ result: @escaping FlutterResult) {
        WortiseAds.shared.wait { result(nil) }
    }
}
