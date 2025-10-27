package com.wortise.ads.flutter.banner

import android.content.Context
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BannerAdViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView = BannerAdView(
        requireNotNull(context),
        viewId,
        requireNotNull(args as? Map<*, *>),
        messenger
    )


    companion object {
        internal const val CHANNEL_ID = "${CHANNEL_MAIN}/bannerAd"
    }
}