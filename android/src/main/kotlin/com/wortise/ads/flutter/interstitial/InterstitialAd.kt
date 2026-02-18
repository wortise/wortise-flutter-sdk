package com.wortise.ads.flutter.interstitial

import android.app.Activity
import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.RevenueData
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.flutter.extensions.toMap
import com.wortise.ads.interstitial.InterstitialAd
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class InterstitialAd : ActivityAware, FlutterPlugin, MethodCallHandler {

    private var activity: Activity? = null

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private lateinit var channel : MethodChannel

    private lateinit var context: Context

    private val instances = mutableMapOf<String, InterstitialAd>()


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding

        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_ID)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "destroy"     -> destroy(call, result)

            "isAvailable" -> isAvailable(call, result)

            "isDestroyed" -> isDestroyed(call, result)

            "loadAd"      -> loadAd(call, result)

            "showAd"      -> showAd(call, result)

            else          -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }


    private fun createInstance(adUnitId: String): InterstitialAd? {
        val activity = activity ?: return null

        val adChannel = MethodChannel(binding.binaryMessenger, "${CHANNEL_ID}_$adUnitId")

        return InterstitialAd(activity, adUnitId).also {

            it.listener = InterstitialAdListener(adChannel)

            instances[adUnitId] = it
        }
    }

    private fun destroy(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        instances.remove(adUnitId)?.destroy()

        result.success(null)
    }

    private fun isAvailable(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val isAvailable = instances[adUnitId]?.isAvailable == true

        result.success(isAvailable)
    }

    private fun isDestroyed(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val isDestroyed = instances[adUnitId]?.isDestroyed == true

        result.success(isDestroyed)
    }

    private fun loadAd(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val interstitialAd = instances[adUnitId] ?: createInstance(adUnitId) ?: run {
            result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
            return
        }

        interstitialAd.loadAd()

        result.success(null)
    }

    private fun showAd(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val interstitialAd = instances[adUnitId]

        if (interstitialAd?.isAvailable != true) {
            result.success(false)
            return
        }

        interstitialAd.showAd()

        result.success(true)
    }


    private class InterstitialAdListener(private val channel: MethodChannel) : InterstitialAd.Listener {

        override fun onInterstitialClicked(ad: InterstitialAd) {
            channel.invokeMethod("clicked", null)
        }

        override fun onInterstitialDismissed(ad: InterstitialAd) {
            channel.invokeMethod("dismissed", null)
        }

        override fun onInterstitialFailedToLoad(ad: InterstitialAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToLoad", values)
        }

        override fun onInterstitialFailedToShow(ad: InterstitialAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToShow", values)
        }

        override fun onInterstitialImpression(ad: InterstitialAd) {
            channel.invokeMethod("impression", null)
        }

        override fun onInterstitialLoaded(ad: InterstitialAd) {
            channel.invokeMethod("loaded", null)
        }

        override fun onInterstitialRevenuePaid(ad: InterstitialAd, data: RevenueData) {
            channel.invokeMethod("revenuePaid", data.toMap())
        }

        override fun onInterstitialShown(ad: InterstitialAd) {
            channel.invokeMethod("shown", null)
        }
    }


    companion object {
        private const val CHANNEL_ID = "${CHANNEL_MAIN}/interstitialAd"
    }
}