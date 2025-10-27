import Flutter
import UIKit
import WortiseSDK

public class WortiseBannerAdViewFactory: NSObject, FlutterPlatformViewFactory {

    internal static let channelId = "\(WortiseFlutterPlugin.channelMain)/bannerAd"


    private var messenger: FlutterBinaryMessenger


    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(
        withFrame      frame:  CGRect,
        viewIdentifier viewId: Int64,
        arguments      args:   Any?
    ) -> FlutterPlatformView {

        let values = args as! [String: Any]

        return WortiseBannerAdView(
            frame:           frame,
            viewIdentifier:  viewId,
            arguments:       values,
            binaryMessenger: messenger
        )
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class WortiseBannerAdView: NSObject, FlutterPlatformView {

    private var bannerAd: WABannerAd

    private var channel: FlutterMethodChannel


    init(
        frame:                     CGRect,
        viewIdentifier  viewId:    Int64,
        arguments       args:      [String: Any],
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let channelId = "\(WortiseBannerAdViewFactory.channelId)_\(viewId)"

        channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger!)

        bannerAd = WABannerAd(frame: frame)

        super.init()

        let adUnitId = args["adUnitId"] as! String

        bannerAd.adSize             = getAdSize(args)
        bannerAd.adUnitId           = adUnitId
        bannerAd.delegate           = self
        bannerAd.rootViewController = WortiseFlutterPlugin.viewController

        if let time = getAutoRefreshTime(args) {
            bannerAd.autoRefreshTime = time
        }

        bannerAd.loadAd()
    }

    public func view() -> UIView {
        return bannerAd
    }


    private func getAdSize(_ args: [String: Any]) -> WAAdSize {

        let params = args["adSize"] as! [String: Any]

        let type = params["type"] as! String

        let height = CGFloat(params["height"] as! Int)
        let width  = CGFloat(params["width"]  as! Int)

        switch type {
        case "anchored":
            return WAAdSize.getAnchoredAdaptiveBannerAdSize(width: width)

        case "inline":
            return WAAdSize.getInlineAdaptiveBannerAdSize(width: width, maxHeight: height)

        default:
            return WAAdSize(width: width, height: height)
        }
    }

    private func getAutoRefreshTime(_ args: [String: Any]) -> Double? {
        guard let time = args["autoRefreshTime"] as? Int else {
            return nil
        }

        return Double(time) / 1000.0
    }
}

extension WortiseBannerAdView: WABannerDelegate {

    public func didClick(bannerAd: WABannerAd) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    public func didFailToLoad(bannerAd: WABannerAd, error: WAAdError) {
        channel.invokeMethod("failedToLoad", arguments: error.toMap())
    }

    public func didImpress(bannerAd: WABannerAd) {
        channel.invokeMethod("impression", arguments: nil)
    }

    public func didLoad(bannerAd: WABannerAd) {
        let values = [
            "adHeight": bannerAd.adHeight,
            "adWidth":  bannerAd.adWidth
        ]

        channel.invokeMethod("loaded", arguments: values)
    }

    public func didPayRevenue(bannerAd: WABannerAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }
}
