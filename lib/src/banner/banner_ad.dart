import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ad_size.dart';
import '../wortise_sdk.dart';

enum BannerAdEvent {
  CLICKED,
  FAILED_TO_LOAD,
  IMPRESSION,
  LOADED,
  REVENUE_PAID,
}

class BannerAd extends StatefulWidget {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/bannerAd";

  static const AUTO_REFRESH_DEFAULT_TIME = 60 * 1000;
  static const AUTO_REFRESH_DISABLED     = -1;
  static const AUTO_REFRESH_MAX_TIME     = 120 * 1000;
  static const AUTO_REFRESH_MIN_TIME     = 30 * 1000;
  static const AUTO_REFRESH_UNSPECIFIED  = 0;


  final AdSize adSize;

  final String adUnitId;

  final int autoRefreshTime;

  final bool keepAlive;

  final void Function(BannerAdEvent, dynamic)? listener;


  const BannerAd({
    Key? key,
    required this.adUnitId,
    this.adSize = AdSize.HEIGHT_50,
    this.autoRefreshTime = 0,
    this.listener,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> with AutomaticKeepAliveClientMixin {

  double? containerHeight;


  @override
  void initState() {
    super.initState();

    _updateState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Map<String, dynamic> params = {
      "adSize": widget.adSize.toMap,
      "adUnitId": widget.adUnitId,
      "autoRefreshTime": widget.autoRefreshTime
    };

    Widget platformView;
    
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidView(
        viewType: BannerAd.CHANNEL_ID,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onViewCreated,
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: BannerAd.CHANNEL_ID,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onViewCreated,
      );
    } else {
      return Container();
    }

    return Container(
      child: platformView,
      color: Colors.transparent,
      height: containerHeight,
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;


  void _updateState({ double? adHeight }) {
    double? height = adHeight;

    if (height == null || height <= 0) {
      height = widget.adSize.height.toDouble();
    }

    if (height <= 0) {
      height = null;
    }

    setState(() {
      containerHeight = height ?? double.infinity;
    });
  }

  void _onViewCreated(int id) {
    final channel = MethodChannel('${BannerAd.CHANNEL_ID}_$id');

    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
      case "clicked":
        widget.listener?.call(BannerAdEvent.CLICKED, call.arguments);
        break;

      case "failedToLoad":
        widget.listener?.call(BannerAdEvent.FAILED_TO_LOAD, call.arguments);
        break;

      case "impression":
        widget.listener?.call(BannerAdEvent.IMPRESSION, call.arguments);
        break;

      case "loaded":
        double? adHeight = call.arguments["adHeight"] as double?;

        _updateState(adHeight: adHeight);

        widget.listener?.call(BannerAdEvent.LOADED, call.arguments);
        
        break;

      case "revenuePaid":
        widget.listener?.call(BannerAdEvent.REVENUE_PAID, call.arguments);
        break;
      }
    });
  }
}