import 'dart:async';

import 'package:flutter/services.dart';

class WortiseSdk {

  static const CHANNEL_MAIN = "wortise";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_MAIN);


  static Future<void> initialize(String assetKey) async {
    Map<String, dynamic> values = {
      'assetKey': assetKey,
    };

    await _channel.invokeMethod('initialize', values);
  }

  static Future<bool> get isInitialized async {
    return await _channel.invokeMethod('isInitialized');
  }

  static Future<bool> get isReady async {
    return await _channel.invokeMethod('isReady');
  }

  static Future<String> get version async {
    return await _channel.invokeMethod('getVersion');
  }

  static Future<void> wait() async {
    await _channel.invokeMethod('wait');
  }
}
