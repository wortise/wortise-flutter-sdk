import 'dart:async';

import 'package:flutter/services.dart';

import 'ad_content_rating.dart';
import 'wortise_sdk.dart';

class AdSettings {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/adSettings";

  static const MethodChannel _channel =
      const MethodChannel(CHANNEL_ID);

  static Future<String?> get assetKey async {
    return await _channel.invokeMethod('getAssetKey');
  }

  static Future<bool> get isChildDirected async {
    return await _channel.invokeMethod('isChildDirected');
  }

  static Future<bool> get isTestEnabled async {
    return await _channel.invokeMethod('isTestEnabled');
  }

  static Future<AdContentRating?> get maxAdContentRating async {
    String? rating = await _channel.invokeMethod('getMaxAdContentRating');

    if (rating == null) {
      return null;
    }

    try {
      return AdContentRating.values.firstWhere((r) => r.name == rating);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> get userId async {
    return await _channel.invokeMethod('getUserId');
  }

  static Future<void> setChildDirected(bool enabled) async {
    Map<String, dynamic> values = {'enabled': enabled};

    await _channel.invokeMethod('setChildDirected', values);
  }

  static Future<void> setMaxAdContentRating(AdContentRating? rating) async {
    String? name = (rating != null) ? rating.name : null;

    Map<String, dynamic> values = {'rating': name};

    await _channel.invokeMethod('setMaxAdContentRating', values);
  }

  static Future<void> setTestEnabled(bool enabled) async {
    Map<String, dynamic> values = {'enabled': enabled};

    await _channel.invokeMethod('setTestEnabled', values);
  }

  static Future<void> setUserId(String? userId) async {
    Map<String, dynamic> values = {'userId': userId};

    await _channel.invokeMethod('setUserId', values);
  }
}
