package com.wortise.ads.flutter.natives

import android.content.Context
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.wortise.ads.AdError
import com.wortise.ads.RevenueData
import com.wortise.ads.flutter.extensions.toMap
import com.wortise.ads.flutter.natives.GoogleNativeAdManager.Companion.CHANNEL_ID
import com.wortise.ads.natives.GoogleNativeAd
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class GoogleNativeAd(
    private val context:    Context,
    private val instanceId: String,
    private val adUnitId:   String, 
    private val adFactory:  GoogleNativeAdFactory,
    messenger: BinaryMessenger
) : GoogleNativeAd.Listener {

    private val channel = MethodChannel(messenger, "${CHANNEL_ID}_$instanceId")

    private val nativeAd by lazy {
        GoogleNativeAd(context, adUnitId, this)
    }


    var nativeAdView: NativeAdView? = null
        private set


    fun destroy() {
        nativeAd.destroy()

        nativeAdView = null
    }

    fun load() {
        nativeAd.load()
    }


    override fun onNativeClicked(ad: GoogleNativeAd) {
        channel.invokeMethod("clicked", null)
    }

    override fun onNativeFailedToLoad(ad: GoogleNativeAd, error: AdError) {
        val values = mapOf("error" to error.name)

        channel.invokeMethod("failedToLoad", values)
    }

    override fun onNativeImpression(ad: GoogleNativeAd) {
        channel.invokeMethod("impression", null)
    }

    override fun onNativeLoaded(ad: GoogleNativeAd, nativeAd: NativeAd) {
        nativeAdView = adFactory.createNativeAd(nativeAd)

        channel.invokeMethod("loaded", null)
    }

    override fun onNativeRevenuePaid(ad: GoogleNativeAd, data: RevenueData) {
        channel.invokeMethod("revenuePaid", data.toMap())
    }
}