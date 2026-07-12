import Flutter
import UIKit

protocol WortiseAdWithView {
  func get(platformView instanceId: String) -> FlutterPlatformView?
}