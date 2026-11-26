import Flutter
import WortiseSDK

class WortisePreloadDelegate: WAPreloadDelegate {

    private let channel: FlutterMethodChannel


    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func didExhaustAds(adUnitId: String) {
        channel.invokeMethod("exhausted", arguments: nil)
    }

    func didFailToPreloadAd(adUnitId: String, error: WAAdError) {
        channel.invokeMethod("failedToPreload", arguments: error.toMap())
    }

    func didPreloadAd(adUnitId: String) {
        channel.invokeMethod("preloaded", arguments: nil)
    }
}
