import Flutter
import UIKit
import WortiseSDK

public class WortisePlatformView: NSObject, FlutterPlatformView {

    private var platformView: UIView


    init(_ view: UIView) {
        platformView = view
        super.init()
    }

    public func view() -> UIView {
        return platformView;
    }
}
