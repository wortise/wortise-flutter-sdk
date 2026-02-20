import 'dart:async';

import 'package:flutter/services.dart';

import 'platform_util.dart';
import 'wortise_sdk.dart';

enum AppOpenAdEvent {
  CLICKED,
  DISMISSED,
  FAILED_TO_LOAD,
  FAILED_TO_SHOW,
  IMPRESSION,
  LOADED,
  REVENUE_PAID,
  SHOWN,
}

class AppOpenAd {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/appOpenAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_ID);


  MethodChannel? _adChannel;

  final String adUnitId;

  final bool autoReload;

  final void Function(AppOpenAdEvent, dynamic)? listener;


  AppOpenAd(this.adUnitId, {this.listener, this.autoReload = false}) {
    if (isSupportedPlatform && listener != null) {
      _adChannel = MethodChannel('${CHANNEL_ID}_$adUnitId');
      _adChannel?.setMethodCallHandler(_handleEvent);
    }
  }

  Future<bool> get isAvailable async {
    if (!isSupportedPlatform) return false;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('isAvailable', values);
  }

  Future<bool> get isDestroyed async {
    if (!isSupportedPlatform) return false;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('isDestroyed', values);
  }

  Future<bool> get isShowing async {
    if (!isSupportedPlatform) return false;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('isShowing', values);
  }

  Future<void> destroy() async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    await _channel.invokeMethod('destroy', values);
  }

  Future<void> loadAd() async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId,
      'autoReload': autoReload
    };

    await _channel.invokeMethod('loadAd', values);
  }

  Future<bool> showAd() async {
    if (!isSupportedPlatform) return false;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('showAd', values);
  }

  Future<bool> tryToShowAd() async {
    if (!isSupportedPlatform) return false;

    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('tryToShowAd', values);
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(AppOpenAdEvent.CLICKED, call.arguments);
      break;

    case "dismissed":
      listener?.call(AppOpenAdEvent.DISMISSED, call.arguments);
      break;

    case "failedToLoad":
      listener?.call(AppOpenAdEvent.FAILED_TO_LOAD, call.arguments);
      break;

    case "failedToShow":
      listener?.call(AppOpenAdEvent.FAILED_TO_SHOW, call.arguments);
      break;

    case "impression":
      listener?.call(AppOpenAdEvent.IMPRESSION, call.arguments);
      break;

    case "loaded":
      listener?.call(AppOpenAdEvent.LOADED, call.arguments);
      break;

    case "revenuePaid":
      listener?.call(AppOpenAdEvent.REVENUE_PAID, call.arguments);
      break;

    case "shown":
      listener?.call(AppOpenAdEvent.SHOWN, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
