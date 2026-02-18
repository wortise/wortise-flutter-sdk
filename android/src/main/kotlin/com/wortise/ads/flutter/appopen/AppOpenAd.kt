package com.wortise.ads.flutter.appopen

import android.app.Activity
import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.RevenueData
import com.wortise.ads.appopen.AppOpenAd
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.flutter.extensions.toMap
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AppOpenAd : ActivityAware, FlutterPlugin, MethodCallHandler {

    private var activity: Activity? = null

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private lateinit var channel : MethodChannel

    private lateinit var context: Context

    private val instances = mutableMapOf<String, AppOpenAd>()


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

            "isShowing"   -> isShowing(call, result)

            "loadAd"      -> loadAd(call, result)

            "showAd"      -> showAd(call, result)

            "tryToShowAd" -> tryToShowAd(call, result)

            else          -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }


    private fun createInstance(adUnitId: String): AppOpenAd? {
        val activity = activity ?: return null

        val adChannel = MethodChannel(binding.binaryMessenger, "${CHANNEL_ID}_$adUnitId")

        return AppOpenAd(activity, adUnitId).also {

            it.listener = AppOpenAdListener(adChannel)

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

    private fun get(adUnitId: String): AppOpenAd? {
        return instances[adUnitId] ?: createInstance(adUnitId)
    }

    private fun isAvailable(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        result.success(instances[adUnitId]?.isAvailable == true)
    }

    private fun isDestroyed(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        result.success(instances[adUnitId]?.isDestroyed == true)
    }

    private fun isShowing(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        result.success(instances[adUnitId]?.isShowing == true)
    }

    private fun loadAd(call: MethodCall, result: Result) {
        val adUnitId    = call.argument<String> ("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }
        val autoReload  = call.argument<Boolean>("autoReload")

        val appOpenAd = get(adUnitId) ?: run {
            result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
            return
        }

        autoReload?.apply { appOpenAd.autoReload = this }

        appOpenAd.loadAd()

        result.success(null)
    }

    private fun showAd(call: MethodCall, result: Result) {
        val activity = activity ?: run {
            result.success(false)
            return
        }

        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val appOpenAd = instances[adUnitId]

        if (appOpenAd?.isAvailable != true) {
            result.success(false)
            return
        }

        appOpenAd.showAd(activity)

        result.success(true)
    }

    private fun tryToShowAd(call: MethodCall, result: Result) {
        val activity = activity ?: run {
            result.success(false)
            return
        }

        val adUnitId = call.argument<String>("adUnitId") ?: run {
            result.error("INVALID_ARGUMENT", "adUnitId is required", null)
            return
        }

        val instance = instances[adUnitId]

        if (instance == null) {
            result.success(false)
            return
        }

        instance.tryToShowAd(activity)

        result.success(true)
    }


    private class AppOpenAdListener(private val channel: MethodChannel) : AppOpenAd.Listener {

        override fun onAppOpenClicked(ad: AppOpenAd) {
            channel.invokeMethod("clicked", null)
        }

        override fun onAppOpenDismissed(ad: AppOpenAd) {
            channel.invokeMethod("dismissed", null)
        }

        override fun onAppOpenFailedToLoad(ad: AppOpenAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToLoad", values)
        }

        override fun onAppOpenFailedToShow(ad: AppOpenAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToShow", values)
        }

        override fun onAppOpenImpression(ad: AppOpenAd) {
            channel.invokeMethod("impression", null)
        }

        override fun onAppOpenLoaded(ad: AppOpenAd) {
            channel.invokeMethod("loaded", null)
        }

        override fun onAppOpenRevenuePaid(ad: AppOpenAd, data: RevenueData) {
            channel.invokeMethod("revenuePaid", data.toMap())
        }

        override fun onAppOpenShown(ad: AppOpenAd) {
            channel.invokeMethod("shown", null)
        }
    }


    companion object {
        const val CHANNEL_ID = "${CHANNEL_MAIN}/appOpenAd"
    }
}