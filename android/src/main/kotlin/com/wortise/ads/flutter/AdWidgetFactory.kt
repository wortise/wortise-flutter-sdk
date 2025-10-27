package com.wortise.ads.flutter

import android.content.Context
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.flutter.views.ErrorTextView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AdWidgetFactory(private val plugin: WortiseFlutterPlugin) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        requireNotNull(context)

        val values = args as? Map<*, *>

        val adId = values?.get("adId") as? String

        requireNotNull(adId)

        return plugin.getPlatformView(adId) ?: ErrorTextView(context, "No ad is available for id $adId")
    }


    companion object {
        internal const val CHANNEL_ID = "${CHANNEL_MAIN}/adWidget"
    }
}