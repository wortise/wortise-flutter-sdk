import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_ad.dart';
import 'native/google_native_ad.dart';
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

  GoogleNativeAd? _googleNativeAd;

  int _viewRevision = 0;


  @override
  void initState() {
    super.initState();

    _updateGoogleNativeAd();
  }

  @override
  void didUpdateWidget(AdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ad != widget.ad) {
      _updateGoogleNativeAd();
    }
  }

  @override
  void dispose() {
    _googleNativeAd?.viewRevision.removeListener(_onViewRevisionChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Map<String, dynamic> params = {
      "adId": widget.ad.adId
    };

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        key: ValueKey('${widget.ad.adId}_$_viewRevision'),
        viewType: AdWidget.CHANNEL_ID,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        key: ValueKey('${widget.ad.adId}_$_viewRevision'),
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


  void _onViewRevisionChanged() {
    if (!mounted) return;

    setState(() {
      _viewRevision = _googleNativeAd?.viewRevision.value ?? 0;
    });
  }

  void _updateGoogleNativeAd() {
    _googleNativeAd?.viewRevision.removeListener(_onViewRevisionChanged);

    _googleNativeAd = widget.ad is GoogleNativeAd ? widget.ad as GoogleNativeAd : null;

    _viewRevision = _googleNativeAd?.viewRevision.value ?? 0;

    _googleNativeAd?.viewRevision.addListener(_onViewRevisionChanged);
  }
}
