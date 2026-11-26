import 'dart:async';

import 'package:flutter/services.dart';

import '../platform_util.dart';
import '../request_parameters.dart';

enum AdPreloadEvent {
  EXHAUSTED,
  FAILED_TO_PRELOAD,
  PRELOADED,
}

class AdPreloader {

  final MethodChannel _channel;

  final String _channelId;


  AdPreloader(this._channelId) : _channel = MethodChannel(_channelId);


  Future<bool> destroy(String adUnitId) async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('destroyPreload', {'adUnitId': adUnitId});
  }

  Future<void> destroyAll() async {
    if (!isSupportedPlatform) return;

    await _channel.invokeMethod('destroyAllPreloads');
  }

  Future<int> getNumAdsAvailable(String adUnitId) async {
    if (!isSupportedPlatform) return 0;

    return await _channel.invokeMethod('getNumAdsAvailable', {'adUnitId': adUnitId});
  }

  Future<bool> isAdAvailable(String adUnitId) async {
    return await getNumAdsAvailable(adUnitId) > 0;
  }

  Future<bool> pollAd(String adUnitId) async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('pollAd', {'adUnitId': adUnitId});
  }

  Future<bool> start(
    String adUnitId, {
    int bufferSize = 1,
    void Function(AdPreloadEvent, dynamic)? listener,
    RequestParameters? requestParameters
  }) async {
    if (!isSupportedPlatform) return false;

    MethodChannel('${_channelId}Preloader_$adUnitId').setMethodCallHandler((call) {
      _handleEvent(call, listener);
      return Future.value(true);
    });

    Map<String, dynamic> values = {
      'adUnitId': adUnitId,
      'bufferSize': bufferSize,
      'requestParameters': requestParameters?.toMap
    };

    return await _channel.invokeMethod('startPreload', values);
  }


  void _handleEvent(MethodCall call, void Function(AdPreloadEvent, dynamic)? listener) {
    switch (call.method) {
    case "exhausted":
      listener?.call(AdPreloadEvent.EXHAUSTED, call.arguments);
      break;

    case "failedToPreload":
      listener?.call(AdPreloadEvent.FAILED_TO_PRELOAD, call.arguments);
      break;

    case "preloaded":
      listener?.call(AdPreloadEvent.PRELOADED, call.arguments);
      break;
    }
  }
}
