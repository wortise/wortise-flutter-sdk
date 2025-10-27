import Flutter
import UIKit
import WortiseSDK

public class WortiseAdWidgetFactory: NSObject, FlutterPlatformViewFactory {

    internal static let channelId = "\(WortiseFlutterPlugin.channelMain)/adWidget"


    private var plugin: WortiseFlutterPlugin


    init(_ plugin: WortiseFlutterPlugin) {
        self.plugin = plugin
        super.init()
    }

    public func create(
        withFrame      frame:  CGRect,
        viewIdentifier viewId: Int64,
        arguments      args:   Any?
    ) -> FlutterPlatformView {

        let values = args as! [String: Any]

        let adId = values["adId"] as! String

        return plugin.get(platformView: adId) ?? WortiseErrorTextView("No ad is available for id \(adId)")
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
