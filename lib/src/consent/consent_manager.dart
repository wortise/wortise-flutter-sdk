import 'dart:async';

import 'package:flutter/services.dart';

import '../wortise_sdk.dart';

class ConsentManager {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/consentManager";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_ID);


  static Future<bool> get canCollectData async {
    return await _channel.invokeMethod('canCollectData');
  }

  static Future<bool> get canRequestPersonalizedAds async {
    return await _channel.invokeMethod('canRequestPersonalizedAds');
  }

  static Future<bool> get exists async {
    return await _channel.invokeMethod('exists');
  }

  static Future<bool> request() async {
    return await _channel.invokeMethod('request');
  }

  static Future<bool> requestIfRequired() async {
    return await _channel.invokeMethod('requestIfRequired');
  }
}
