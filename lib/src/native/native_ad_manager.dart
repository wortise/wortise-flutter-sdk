import 'package:flutter/services.dart';

import '../wortise_sdk.dart';

class NativeAdManager {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/nativeAd";

  static const MethodChannel _methodChannel = const MethodChannel(CHANNEL_ID);


  static Future<void> destroy(String adUnitId) async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    await _methodChannel.invokeMethod('destroy', values);
  }

  static Future<void> destroyAd(String adId) async {
    Map<String, dynamic> values = {
      'adId': adId
    };

    await _methodChannel.invokeMethod('destroyAd', values);
  }

  static Future<void> loadAd({
    required String adUnitId,
    required String factoryId
  }) async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId,
      'factoryId': factoryId
    };

    await _methodChannel.invokeMethod('loadAd', values);
  }
}
