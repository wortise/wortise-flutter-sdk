import Flutter
import UIKit

class WortiseAppLifecycleManager: NSObject, FlutterPlugin {

    static let channelId = "\(WortiseFlutterPlugin.channelMain)/lifecycle"


    fileprivate var channel: FlutterMethodChannel


    public static func register(with registrar: FlutterPluginRegistrar) {
        let binaryMessenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: channelId, binaryMessenger: binaryMessenger)

        let instance = WortiseAppLifecycleManager(channel)

        registrar.addMethodCallDelegate(instance, channel: channel)
    }


    init(_ channel: FlutterMethodChannel) {
        self.channel = channel

        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @objc func appWillEnterForeground() {
        channel.invokeMethod("foreground", arguments: nil)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }
}
