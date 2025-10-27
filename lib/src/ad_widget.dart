import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_ad.dart';
import 'wortise_sdk.dart';

class AdWidget extends StatefulWidget {

  static const CHANNEL_ID = "${WortiseSdk.CHANNEL_MAIN}/adWidget";


  final BaseAd ad;

  final bool keepAlive;


  const AdWidget({
    Key? key,
    required this.ad,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _AdWidgetState createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Map<String, dynamic> params = {
      "adId": widget.ad.adId
    };

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: AdWidget.CHANNEL_ID,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: AdWidget.CHANNEL_ID,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return Container();
    }
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}