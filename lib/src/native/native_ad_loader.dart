import 'dart:async';

import 'package:flutter/services.dart';

import 'native_ad.dart';
import 'native_ad_manager.dart';

enum NativeAdEvent {
  CLICKED,
  FAILED,
  IMPRESSION,
  LOADED,
  REVENUE_PAID,
}

class NativeAdLoader {

  MethodChannel? _channel;


  final String adUnitId;

  final String factoryId;

  final void Function(NativeAdEvent, dynamic)? listener;


  NativeAdLoader(this.adUnitId, this.factoryId, this.listener) {    
    if (listener != null) {
      _channel = MethodChannel('${NativeAdManager.CHANNEL_ID}_$adUnitId');
      _channel?.setMethodCallHandler(_handleEvent);
    }
  }

  Future<void> destroy() async {
    await NativeAdManager.destroy(adUnitId);
  }

  Future<void> loadAd() async {
    await NativeAdManager.loadAd(
      adUnitId: adUnitId,
      factoryId: factoryId
    );
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(NativeAdEvent.CLICKED, call.arguments);
      break;

    case "failed":
      listener?.call(NativeAdEvent.FAILED, call.arguments);
      break;

    case "impression":
      listener?.call(NativeAdEvent.IMPRESSION, call.arguments);
      break;

    case "loaded":
      final adId = call.arguments["adId"] as String;

      final nativeAd = NativeAd(adId);

      Map<String, dynamic> values = {
        'ad': nativeAd
      };

      listener?.call(NativeAdEvent.LOADED, values);
      break;
    
    case "revenuePaid":
      listener?.call(NativeAdEvent.REVENUE_PAID, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
