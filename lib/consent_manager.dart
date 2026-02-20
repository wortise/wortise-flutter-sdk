import 'dart:async';

import 'package:flutter/services.dart';

import 'platform_util.dart';
import 'wortise_sdk.dart';

class ConsentManager {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/consentManager";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_ID);


  static Future<bool> get canCollectData async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('canCollectData');
  }

  static Future<bool> get canRequestPersonalizedAds async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('canRequestPersonalizedAds');
  }

  static Future<bool> get exists async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('exists');
  }

  static Future<bool> request() async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('request');
  }

  static Future<bool> requestIfRequired() async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('requestIfRequired');
  }
}
