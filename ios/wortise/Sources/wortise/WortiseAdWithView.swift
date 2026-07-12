import Flutter
import UIKit

protocol WortiseAdWithView {
  func get(platformView adId: String) -> FlutterPlatformView?
}