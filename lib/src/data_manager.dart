import 'dart:async';

import 'package:flutter/services.dart';

import 'platform_util.dart';
import 'user_gender.dart';
import 'wortise_sdk.dart';

class DataManager {
  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/dataManager";

  static const MethodChannel _channel =
      const MethodChannel(CHANNEL_ID);


  static Future<int?> get age async {
    if (!isSupportedPlatform) return null;

    return await _channel.invokeMethod('getAge');
  }

  static Future<List<String>> get emails async {
    if (!isSupportedPlatform) return [];

    List<dynamic>? list = await _channel.invokeMethod('getEmails');

    return list?.cast<String>() ?? [];
  }

  static Future<UserGender?> get gender async {
    if (!isSupportedPlatform) return null;

    String? gender = await _channel.invokeMethod('getGender');

    if (gender == null) {
      return null;
    }

    try {
      return UserGender.values.firstWhere((g) => g.name == gender);
    } catch (_) {
      return null;
    }
  }


  static Future<void> addEmail(String email) async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {'email': email};

    await _channel.invokeMethod('addEmail', values);
  }

  static Future<void> setAge(int age) async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {'age': age};

    await _channel.invokeMethod('setAge', values);
  }

  static Future<void> setEmails(List<String>? list) async {
    if (!isSupportedPlatform) return;

    Map<String, dynamic> values = {'list': list};

    await _channel.invokeMethod('setEmails', values);
  }

  static Future<void> setGender(UserGender? gender) async {
    if (!isSupportedPlatform) return;

    String? name = (gender != null) ? gender.name : null;

    Map<String, dynamic> values = {'gender': name};

    await _channel.invokeMethod('setGender', values);
  }
}
