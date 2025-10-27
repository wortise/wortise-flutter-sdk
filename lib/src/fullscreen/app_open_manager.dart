import 'dart:async';

import 'package:flutter/material.dart';

import 'app_open_ad.dart';

class AppOpenManager extends WidgetsBindingObserver {

  final AppOpenAd appOpenAd;


  AppOpenManager(this.appOpenAd);

  AppOpenManager.register(this.appOpenAd) {
    WidgetsBinding.instance.addObserver(this);
  }


  void destroy() {
    appOpenAd.destroy();
  }

  void loadAd() {
    appOpenAd.loadAd();
  }


  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      appOpenAd.tryToShowAd();
    }
  }
}
