import 'dart:async';

import '../request_parameters.dart';
import 'ad_preloader.dart';
import 'interstitial_ad.dart';

class InterstitialAdPreloader {

  static final AdPreloader _preloader = AdPreloader(InterstitialAd.CHANNEL_ID);


  static Future<bool> destroy(String adUnitId) => _preloader.destroy(adUnitId);

  static Future<void> destroyAll() => _preloader.destroyAll();

  static Future<int> getNumAdsAvailable(String adUnitId) => _preloader.getNumAdsAvailable(adUnitId);

  static Future<bool> isAdAvailable(String adUnitId) => _preloader.isAdAvailable(adUnitId);

  static Future<InterstitialAd?> pollAd(String adUnitId, {void Function(InterstitialAdEvent, dynamic)? listener}) async {
    final bool polled = await _preloader.pollAd(adUnitId);

    return polled ? InterstitialAd(adUnitId, listener: listener) : null;
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
