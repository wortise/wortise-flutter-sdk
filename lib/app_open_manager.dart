import 'dart:async';

import 'package:flutter/services.dart';

import 'app_open_ad.dart';
import 'platform_util.dart';
import 'wortise_sdk.dart';

class AppOpenManager {

  static const _channel = MethodChannel('${WortiseSdk.CHANNEL_MAIN}/lifecycle');

  final AppOpenAd appOpenAd;


  AppOpenManager(this.appOpenAd);

  AppOpenManager.register(this.appOpenAd) {
    if (isSupportedPlatform) {
      _channel.setMethodCallHandler(_handleLifecycleEvent);
    }
  }


  void destroy() {
    if (!isSupportedPlatform) return;

    _channel.setMethodCallHandler(null);

    appOpenAd.destroy();
  }

  void loadAd() {
    appOpenAd.loadAd();
  }


  Future<dynamic> _handleLifecycleEvent(MethodCall call) async {
    if (call.method == 'foreground') {
      appOpenAd.showAd();
    }
  }
}
