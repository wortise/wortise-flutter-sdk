import Flutter
import UIKit
import WortiseSDK

public class WortiseConsentManager: NSObject, FlutterPlugin {

    private static let channelId = "\(WortiseFlutterPlugin.channelMain)/consentManager"


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: registrar.messenger())

        let instance = WortiseConsentManager()

        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "canCollectData":
            result(WAConsentManager.shared.canCollectData)

        case "canRequestPersonalizedAds":
            result(WAConsentManager.shared.canRequestPersonalizedAds)

        case "exists":
            result(WAConsentManager.shared.exists)

        case "request":
            request(args, result: result)

        case "requestIfRequired":
            requestIfRequired(args, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    private func request(_ args: [String: Any]?, result: @escaping FlutterResult) {
        WAConsentManager.shared.request(WortiseFlutterPlugin.viewController!) {
            result($0)
        }
    }

    private func requestIfRequired(_ args: [String: Any]?, result: @escaping FlutterResult) {
        WAConsentManager.shared.request(ifRequired: WortiseFlutterPlugin.viewController!) {
            result($0)
        }
    }
}
