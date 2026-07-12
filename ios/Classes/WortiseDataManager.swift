import Flutter
import UIKit

public class WortiseDataManager: NSObject, FlutterPlugin {

    private static let channelId = "\(WortiseFlutterPlugin.channelMain)/dataManager"


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: registrar.messenger())

        let instance = WortiseDataManager()

        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addEmail":
            result(nil)

        case "getAge":
            result(nil)

        case "getEmails":
            result(nil)

        case "getGender":
            result(nil)

        case "setAge":
            result(nil)

        case "setEmails":
            result(nil)

        case "setGender":
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}