package com.wortise.ads.flutter.natives

import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.RevenueData
import com.wortise.ads.flutter.AdWithView
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.flutter.extensions.toMap
import com.wortise.ads.flutter.views.FlutterPlatformView
import com.wortise.ads.natives.NativeAd
import com.wortise.ads.natives.NativeAdLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView

class NativeAdManager : AdWithView, FlutterPlugin, MethodCallHandler {

    private val adInstances = mutableMapOf<String, NativeAd>()

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private lateinit var channel : MethodChannel

    private lateinit var context: Context

    private val instances = mutableMapOf<String, NativeAdLoader>()

    private var lastAdId = 0


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding

        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_ID)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "destroy"     -> destroy(call, result)

            "destroyAd"   -> destroyAd(call, result)

            "isDestroyed" -> isDestroyed(call, result)

            "loadAd"      -> loadAd(call, result)

            else          -> result.notImplemented()
        }
    }


    private fun createInstance(adUnitId: String, factory: NativeAdViewFactory): NativeAdLoader {
        val listener = NativeAdListener(adUnitId, factory)

        return NativeAdLoader(context, adUnitId, listener).also {
            instances[adUnitId] = it
        }
    }

    private fun destroy(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        instances.remove(adUnitId)?.destroy()

        result.success(null)
    }

    private fun destroyAd(call: MethodCall, result: Result) {
        val adId = call.argument<String>("adId")

        requireNotNull(adId)

        adInstances.remove(adId)?.destroy()

        result.success(null)
    }

    private fun isDestroyed(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val isDestroyed = instances[adUnitId]?.isDestroyed == true

        result.success(isDestroyed)
    }

    private fun loadAd(call: MethodCall, result: Result) {
        val adUnitId  = call.argument<String>("adUnitId")
        val factoryId = call.argument<String>("factoryId")

        requireNotNull(adUnitId)
        requireNotNull(factoryId)

        val factory = adViewFactories[factoryId]

        if (factory == null) {
            result.error("NativeAdError", "Can't find NativeAdViewFactory with id: $factoryId", null)
            return
        }

        val loader = instances[adUnitId] ?: createInstance(adUnitId, factory)

        loader.loadAd()

        result.success(null)
    }


    override fun getPlatformView(adId: String): PlatformView? {
        val adView = adInstances[adId]?.adView ?: return null

        return FlutterPlatformView(adView)
    }


    private inner class NativeAdListener(
        private val adUnitId: String,
        private val factory:  NativeAdViewFactory
    ) : NativeAdLoader.Listener {

        private val channel = MethodChannel(binding.binaryMessenger, "${CHANNEL_ID}_$adUnitId")


        override fun onNativeClicked(ad: NativeAd) {
            channel.invokeMethod("clicked", null)
        }

        override fun onNativeFailedToLoad(error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToLoad", values)
        }

        override fun onNativeImpression(ad: NativeAd) {
            channel.invokeMethod("impression", null)
        }

        override fun onNativeLoaded(ad: NativeAd) {
            val loader = instances[adUnitId] ?: return

            val adView = factory.createNativeAdView()

            if (!loader.renderAd(adView, ad)) {
                onNativeFailedToLoad(AdError.RENDER_ERROR)
                return
            }

            val adId = (++lastAdId).toString()

            adInstances[adId] = ad

            val values = mapOf("adId" to adId)

            channel.invokeMethod("loaded", values)
        }

        override fun onNativeRevenuePaid(ad: NativeAd, data: RevenueData) {
            channel.invokeMethod("revenuePaid", data.toMap())
        }
    }


    companion object {

        private const val CHANNEL_ID = "${CHANNEL_MAIN}/nativeAd"


        private val adViewFactories = mutableMapOf<String, NativeAdViewFactory>()


        @JvmStatic
        fun registerAdViewFactory(id: String, instance: NativeAdViewFactory) {
            adViewFactories[id] = instance
        }

        @JvmStatic
        fun unregisterAdViewFactory(id: String) {
            adViewFactories.remove(id)
        }
    }
}