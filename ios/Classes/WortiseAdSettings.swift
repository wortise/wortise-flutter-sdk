import Flutter
import UIKit
import WortiseSDK

public class WortiseAdSettings: NSObject, FlutterPlugin {

    public static let channelId = "\(WortiseFlutterPlugin.channelMain)/adSettings"
    

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: registrar.messenger())

        let instance = WortiseAdSettings()

        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "getAssetKey":
            result(WAAdSettings.assetKey)

        case "getMaxAdContentRating":
            result(WAAdSettings.maxAdContentRating?.name)

        case "getUserId":
            result(nil)

        case "isChildDirected":
            result(WAAdSettings.childDirected)

        case "isTestEnabled":
            result(WAAdSettings.testEnabled)

        case "setChildDirected":
            setChildDirected(args, result: result)

        case "setMaxAdContentRating":
            setMaxAdContentRating(args, result: result)

        case "setTestEnabled":
            setTestEnabled(args, result: result)

        case "setUserId":
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    fileprivate func setChildDirected(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let enabled = args?["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
            return
        }

        WAAdSettings.childDirected = enabled

        result(nil)
    }

    fileprivate func setMaxAdContentRating(_ args: [String: Any]?, result: @escaping FlutterResult) {
        let name = args?["rating"] as? String

        WAAdSettings.maxAdContentRating = name != nil ? WAAdContentRating.from(name: name!) : nil

        result(nil)
    }

    fileprivate func setTestEnabled(_ args: [String: Any]?, result: @escaping FlutterResult) {
        guard let enabled = args?["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
            return
        }

        WAAdSettings.testEnabled = enabled

        result(nil)
    }
}
