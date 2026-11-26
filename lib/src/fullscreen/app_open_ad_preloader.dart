import 'dart:async';

import '../request_parameters.dart';
import 'ad_preloader.dart';
import 'app_open_ad.dart';

class AppOpenAdPreloader {

  static final AdPreloader _preloader = AdPreloader(AppOpenAd.CHANNEL_ID);


  static Future<bool> destroy(String adUnitId) => _preloader.destroy(adUnitId);

  static Future<void> destroyAll() => _preloader.destroyAll();

  static Future<int> getNumAdsAvailable(String adUnitId) => _preloader.getNumAdsAvailable(adUnitId);

  static Future<bool> isAdAvailable(String adUnitId) => _preloader.isAdAvailable(adUnitId);

  static Future<AppOpenAd?> pollAd(String adUnitId, {void Function(AppOpenAdEvent, dynamic)? listener}) async {
    final bool polled = await _preloader.pollAd(adUnitId);

    return polled ? AppOpenAd(adUnitId, listener: listener) : null;
  }

  static Future<bool> start(
    String adUnitId, {
    int bufferSize = 1,
    void Function(AdPreloadEvent, dynamic)? listener,
    RequestParameters? requestParameters
  }) => _preloader.start(
    adUnitId,
    bufferSize: bufferSize,
    listener: listener,
    requestParameters: requestParameters
  );
}
