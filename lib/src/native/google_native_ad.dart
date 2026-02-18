import 'dart:async';

import 'package:flutter/services.dart';

import '../base_ad.dart';
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

  final String adId = (_currentId++).toString();

  final String adUnitId;

  final String factoryId;

  final void Function(GoogleNativeAdEvent, dynamic)? listener;


  GoogleNativeAd(this.adUnitId, this.factoryId, this.listener) {    
    if (listener != null) {
      _adChannel = MethodChannel('${CHANNEL_ID}_$adId');
      _adChannel?.setMethodCallHandler(_handleEvent);
    }
  }

  Future<void> destroy() async {
    Map<String, dynamic> values = {
      'instanceId': adId
    };

    await _channel.invokeMethod('destroy', values);
  }

  Future<void> load() async {
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
      listener?.call(GoogleNativeAdEvent.LOADED, call.arguments);
      break;
    
    case "revenuePaid":
      listener?.call(GoogleNativeAdEvent.REVENUE_PAID, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
