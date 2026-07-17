package com.wortise.ads.flutter.banner

import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.AdSize
import com.wortise.ads.RevenueData
import com.wortise.ads.banner.BannerAd
import com.wortise.ads.flutter.banner.BannerAdViewFactory.Companion.CHANNEL_ID
import com.wortise.ads.flutter.extensions.getRequestParameters
import com.wortise.ads.flutter.extensions.toMap
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class BannerAdView(private val context: Context, viewId: Int, args: Map<*, *>, messenger: BinaryMessenger) : BannerAd.Listener, PlatformView {

    private val adUnitId = args["adUnitId"] as String

    private val autoRefreshTime = args["autoRefreshTime"] as? Int

    private val bannerAd: BannerAd

    private val channel = MethodChannel(messenger, "${CHANNEL_ID}_$viewId")

    private val requestParameters = getRequestParameters(args)


    init {
        bannerAd = BannerAd(context).also {
            it.adSize   = getAdSize(args)
            it.adUnitId = adUnitId
            it.listener = this

            autoRefreshTime?.apply { it.autoRefreshTime = toLong() }

            it.loadAd(requestParameters)
        }
    }

    override fun dispose() {
        bannerAd.destroy()
    }

    override fun getView() = bannerAd


    override fun onBannerClicked(ad: BannerAd) {
        channel.invokeMethod("clicked", null)
    }

    override fun onBannerFailedToLoad(ad: BannerAd, error: AdError) {
        val values = mapOf("error" to error.name)

        channel.invokeMethod("failedToLoad", values)
    }

    override fun onBannerImpression(ad: BannerAd) {
        channel.invokeMethod("impression", null)
    }

    override fun onBannerLoaded(ad: BannerAd) {
        val values = mapOf(
            "adHeight" to ad.adHeight.toDouble(),
            "adWidth"  to ad.adWidth .toDouble()
        )

        channel.invokeMethod("loaded", values)
    }

    override fun onBannerRevenuePaid(ad: BannerAd, data: RevenueData) {
        channel.invokeMethod("revenuePaid", data.toMap())
    }


    private fun getAdSize(args: Map<*, *>): AdSize {
        val params = args["adSize"] as Map<String, *>

        val height = params["height"] as Int
        val type   = params["type"]   as String
        val width  = params["width"]  as Int

        return when (type) {

            "anchored" -> AdSize.getAnchoredAdaptiveBannerAdSize(context, width)

            "inline"   -> AdSize.getInlineAdaptiveBannerAdSize(context, width, height)

            else       -> AdSize(width = width, height = height)
        }
    }
}