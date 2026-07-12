import Flutter
import GoogleMobileAds
import UIKit
import WortiseSDK

public class WortiseGoogleNativeAd: NSObject {

    fileprivate var adFactory: WortiseGoogleNativeAdFactory

    fileprivate var adUnitId: String

    fileprivate var channel: FlutterMethodChannel

    fileprivate lazy var nativeAd: WAGoogleNativeAd = {
        WAGoogleNativeAd(
            adUnitId:           adUnitId,
            rootViewController: WortiseFlutterPlugin.viewController,
            delegate:           self
        )
    }()

    fileprivate(set) var nativeAdView: NativeAdView? = nil


    init(
        viewIdentifier  viewId:    String,
        adUnitId:                  String,
        adFactory:                 WortiseGoogleNativeAdFactory,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let channelId = "\(WortiseGoogleNativeAdManager.channelId)_\(viewId)"

        channel = FlutterMethodChannel(name: channelId, binaryMessenger: messenger)

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

    public func didPay(revenue nativeAd: WAGoogleNativeAd, data: WARevenueData) {
        channel.invokeMethod("revenuePaid", arguments: data.toMap())
    }

    public func didRecord(impression: WAGoogleNativeAd) {
        channel.invokeMethod("impression", arguments: nil)
    }
}

public protocol WortiseGoogleNativeAdFactory {
    func create(nativeAd: NativeAd) -> NativeAdView
}
