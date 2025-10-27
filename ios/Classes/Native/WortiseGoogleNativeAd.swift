import Flutter
import GoogleMobileAds
import UIKit
import WortiseSDK

public class WortiseGoogleNativeAd: NSObject {

    private var adFactory: WortiseGoogleNativeAdFactory

    private var adUnitId: String

    private var channel: FlutterMethodChannel

    private lazy var nativeAd: WAGoogleNativeAd = {
        WAGoogleNativeAd(
            adUnitId:           adUnitId,
            rootViewController: WortiseFlutterPlugin.viewController,
            delegate:           self
        )
    }()

    private(set) var nativeAdView: NativeAdView?


    init(
        viewIdentifier  viewId:    String,
        adUnitId:                  String,
        adFactory:                 WortiseGoogleNativeAdFactory,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        let channelId = "\(WortiseGoogleNativeAdManager.channelId)_\(viewId)"

        channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger!)

        self.adFactory = adFactory
        self.adUnitId  = adUnitId

        super.init()
    }

    public func destroy() {
        nativeAd.destroy()

        nativeAdView = nil
    }

    public func load() {
        nativeAd.load()
    }
}

extension WortiseGoogleNativeAd: WAGoogleNativeDelegate {

    public func didClick(nativeAd: WAGoogleNativeAd) {
        channel.invokeMethod("clicked", arguments: nil)
    }

    public func didFailToLoad(nativeAd: WAGoogleNativeAd, error: WAAdError) {
        channel.invokeMethod("failedToLoad", arguments: error.toMap())
    }

    public func didLoad(nativeAd: WAGoogleNativeAd, googleNativeAd: NativeAd) {
        nativeAdView = adFactory.create(nativeAd: googleNativeAd)

        channel.invokeMethod("loaded", arguments: nil)
    }

    public func didPayRevenue(nativeAd: WAGoogleNativeAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }

    public func didRecord(impression: WAGoogleNativeAd) {
        channel.invokeMethod("impression", arguments: nil)
    }
}

public protocol WortiseGoogleNativeAdFactory {
    func create(nativeAd: NativeAd) -> NativeAdView
}
