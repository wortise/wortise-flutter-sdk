package com.wortise.ads.flutter.natives

import android.content.Context
import com.wortise.ads.flutter.AdWithView
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.flutter.views.FlutterPlatformView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformView

class GoogleNativeAdManager : AdWithView, FlutterPlugin, MethodCallHandler {

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private lateinit var channel : MethodChannel

    private lateinit var context: Context

    private val instances = mutableMapOf<String, GoogleNativeAd>()


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

            "destroy" -> destroy(call, result)

            "load"    -> load(call, result)

            else      -> result.notImplemented()
        }
    }


    private fun clear(adId: String) {
        instances.remove(adId)?.destroy()
    }

    private fun createInstance(adId: String, adUnitId: String, adFactory: GoogleNativeAdFactory): GoogleNativeAd {
        clear(adId)

        return GoogleNativeAd(context, adId, adUnitId, adFactory, binding.binaryMessenger).also {
            instances[adId] = it
        }
    }

    private fun destroy(call: MethodCall, result: Result) {
        val adId = call.argument<String>("adId") ?: run {
            result.error("INVALID_ARGUMENT", "adId is required", null)
            return
        }

        clear(adId)

        result.success(null)
    }

    private fun load(call: MethodCall, result: Result) {
        val adId = call.argument<String>("adId") ?: run {
            result.error("INVALID_ARGUMENT", "adId is required", null)
            return
        }

        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val factoryId = call.argument<String>("factoryId") ?: run {
            result.error("INVALID_ARGUMENT", "factoryId is required", null)
            return
        }

        val adFactory = adFactories[factoryId]

        if (adFactory == null) {
            result.error("GoogleNativeAdError", "Can't find NativeAdFactory with id: $factoryId", null)
            return
        }

        val nativeAd = createInstance(adId, adUnitId, adFactory)

        nativeAd.load()

        result.success(null)
    }


    override fun getPlatformView(adId: String): PlatformView? {
        val nativeAdView = instances[adId]?.nativeAdView ?: return null

        return FlutterPlatformView(nativeAdView)
    }


    companion object {

        const val CHANNEL_ID = "${CHANNEL_MAIN}/nativeAd"


        private val adFactories = mutableMapOf<String, GoogleNativeAdFactory>()


        @JvmStatic
        fun registerAdFactory(id: String, instance: GoogleNativeAdFactory) {
            adFactories[id] = instance
        }

        @JvmStatic
        fun unregisterAdFactory(id: String) {
            adFactories.remove(id)
        }
    }
}