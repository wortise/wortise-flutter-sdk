import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../base_ad.dart';
import '../platform_util.dart';
import '../wortise_sdk.dart';

enum GoogleNativeAdEvent {
  CLICKED,
  FAILED,
  IMPRESSION,
  LOADED,
  REVENUE_PAID,
}

class GoogleNativeAd extends BaseAd {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/googleNativeAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_ID);


  static int _currentId = 1;


  MethodChannel? _adChannel;

  final String adId = 'google-native-${_currentId++}';

  final String adUnitId;

  final String factoryId;

  final void Function(GoogleNativeAdEvent, dynamic)? listener;

  final ValueNotifier<int> viewRevision = ValueNotifier(0);


  GoogleNativeAd(this.adUnitId, this.factoryId, this.listener) {
    if (isSupportedPlatform) {
      _adChannel = MethodChannel('${CHANNEL_ID}_$adId');
    }
  }

  Future<void> destroy() async {
    if (!isSupportedPlatform) return;

    _adChannel?.setMethodCallHandler(null);

    Map<String, dynamic> values = {
      'instanceId': adId
    };

    await _channel.invokeMethod('destroy', values);
  }

  Future<void> load() async {
    if (!isSupportedPlatform) return;

    _adChannel?.setMethodCallHandler(_handleEvent);

    Map<String, dynamic> values = {
      'adUnitId':   adUnitId,
      'factoryId':  factoryId,
      'instanceId': adId
    };

    await _channel.invokeMethod('load', values);
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(GoogleNativeAdEvent.CLICKED, call.arguments);
      break;

    case "failedToLoad":
      listener?.call(GoogleNativeAdEvent.FAILED, call.arguments);
      break;

    case "impression":
      listener?.call(GoogleNativeAdEvent.IMPRESSION, call.arguments);
      break;

    case "loaded":
      viewRevision.value++;
      listener?.call(GoogleNativeAdEvent.LOADED, call.arguments);
      break;

    case "revenuePaid":
      listener?.call(GoogleNativeAdEvent.REVENUE_PAID, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
