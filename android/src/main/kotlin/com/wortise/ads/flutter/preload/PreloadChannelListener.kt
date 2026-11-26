package com.wortise.ads.flutter.preload

import com.wortise.ads.AdError
import com.wortise.ads.preload.PreloadListener
import io.flutter.plugin.common.MethodChannel

class PreloadChannelListener(private val channel: MethodChannel) : PreloadListener {

    override fun onAdFailedToPreload(adUnitId: String, error: AdError) {
        val values = mapOf("error" to error.name)

        channel.invokeMethod("failedToPreload", values)
    }

    override fun onAdPreloaded(adUnitId: String) {
        channel.invokeMethod("preloaded", null)
    }

    override fun onAdsExhausted(adUnitId: String) {
        channel.invokeMethod("exhausted", null)
    }
}
