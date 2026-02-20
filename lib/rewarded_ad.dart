import 'dart:async';

import 'package:flutter/services.dart';

import 'platform_util.dart';
import 'wortise_sdk.dart';

enum RewardedAdEvent {
  CLICKED,
  COMPLETED,
  DISMISSED,
  FAILED_TO_LOAD,
  FAILED_TO_SHOW,
  IMPRESSION,
  LOADED,
  REVENUE_PAID,
  SHOWN,
}

class RewardedAd {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/rewardedAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_ID);


  MethodChannel? _adChannel;

  final String adUnitId;

  final void Function(RewardedAdEvent, dynamic)? listener;

  final bool reloadOnDismissed;


  RewardedAd(this.adUnitId, {this.listener, this.reloadOnDismissed = false}) {
    if (isSupportedPlatform) {
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
      'adUnitId': adUnitId
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


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(RewardedAdEvent.CLICKED, call.arguments);
      break;

    case "completed":
      listener?.call(RewardedAdEvent.COMPLETED, call.arguments);
      break;

    case "dismissed":
      listener?.call(RewardedAdEvent.DISMISSED, call.arguments);

      if (reloadOnDismissed) {
        loadAd();
      }

      break;

    case "failedToLoad":
      listener?.call(RewardedAdEvent.FAILED_TO_LOAD, call.arguments);
      break;

    case "failedToShow":
      listener?.call(RewardedAdEvent.FAILED_TO_SHOW, call.arguments);
      break;

    case "impression":
      listener?.call(RewardedAdEvent.IMPRESSION, call.arguments);
      break;

    case "loaded":
      listener?.call(RewardedAdEvent.LOADED, call.arguments);
      break;

    case "revenuePaid":
      listener?.call(RewardedAdEvent.REVENUE_PAID, call.arguments);
      break;

    case "shown":
      listener?.call(RewardedAdEvent.SHOWN, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
