import 'dart:async';

import 'package:flutter/services.dart';

import 'ad_content_rating.dart';
import 'platform_util.dart';
import 'wortise_sdk.dart';

class AdSettings {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/adSettings";

  static const MethodChannel _channel =
      const MethodChannel(CHANNEL_ID);

  static Future<String?> get assetKey async {
    if (!isSupportedPlatform) return null;

    return await _channel.invokeMethod('getAssetKey');
  }

  static Future<bool> get isChildDirected async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('isChildDirected');
  }

  static Future<bool> get isTestEnabled async {
    if (!isSupportedPlatform) return false;

    return await _channel.invokeMethod('isTestEnabled');
  }

  static Future<AdContentRating?> get maxAdContentRating async {
    if (!isSupportedPlatform) return null;

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
    if (!isSupportedPlatform) return null;

    return await _channel.invokeMethod('getUserId');
  }

  static Future<void> setChildDirected(bool enabled) async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {'enabled': enabled};

    await _channel.invokeMethod('setChildDirected', values);
  }

  static Future<void> setMaxAdContentRating(AdContentRating? rating) async {
    if (!isSupportedPlatform) return;

    String? name = (rating != null) ? rating.name : null;

    Map<String, dynamic> values = {'rating': name};

    await _channel.invokeMethod('setMaxAdContentRating', values);
  }

  static Future<void> setTestEnabled(bool enabled) async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {'enabled': enabled};

    await _channel.invokeMethod('setTestEnabled', values);
  }

  static Future<void> setUserId(String? userId) async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {'userId': userId};

    await _channel.invokeMethod('setUserId', values);
  }
}
