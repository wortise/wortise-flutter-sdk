package com.wortise.ads.flutter

import android.content.Context
import com.wortise.ads.WortiseSdk
import com.wortise.ads.flutter.appopen.AppOpenAd
import com.wortise.ads.flutter.banner.BannerAdViewFactory
import com.wortise.ads.flutter.interstitial.InterstitialAd
import com.wortise.ads.flutter.natives.GoogleNativeAdManager
import com.wortise.ads.flutter.natives.NativeAdManager
import com.wortise.ads.flutter.rewarded.RewardedAd
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class WortiseFlutterPlugin : ActivityAware, FlutterPlugin, MethodCallHandler {

    private val activityAwarePlugins: List<ActivityAware>
        get() = plugins.mapNotNull { it as? ActivityAware }

    private val plugins = listOf<FlutterPlugin>(
        AdSettings           (),
        AppOpenAd            (),
        ConsentManager       (),
        DataManager          (),
        GoogleNativeAdManager(),
        InterstitialAd       (),
        NativeAdManager      (),
        RewardedAd           ()
    )


    private lateinit var channel : MethodChannel

    private lateinit var context: Context


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityAwarePlugins.forEach { it.onAttachedToActivity(binding) }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_MAIN)
        channel.setMethodCallHandler(this)

        plugins.forEach { it.onAttachedToEngine(binding) }

        binding.platformViewRegistry.registerViewFactory(
            AdWidgetFactory.CHANNEL_ID,
            AdWidgetFactory(this)
        )

        binding.platformViewRegistry.registerViewFactory(
            BannerAdViewFactory.CHANNEL_ID,
            BannerAdViewFactory(binding.binaryMessenger)
        )
    }

    override fun onDetachedFromActivity() {
        activityAwarePlugins.forEach { it.onDetachedFromActivity() }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityAwarePlugins.forEach { it.onDetachedFromActivityForConfigChanges() }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)

        plugins.forEach { it.onDetachedFromEngine(binding) }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "getVersion"    -> result.success(WortiseSdk.version)

            "initialize"    -> initialize(call, result)

            "isInitialized" -> result.success(WortiseSdk.isInitialized)

            "isReady"       -> result.success(WortiseSdk.isReady)

            "wait"          -> wait(result)

            else            -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityAwarePlugins.forEach { it.onReattachedToActivityForConfigChanges(binding) }
    }


    private fun initialize(call: MethodCall, result: Result) {
        val assetKey = call.argument<String>("assetKey")

        require(!assetKey.isNullOrEmpty())

        WortiseSdk.initialize(context, assetKey) {
            result.success(null)
        }
    }

    private fun wait(result: Result) {
        WortiseSdk.wait { result.success(null) }
    }


    fun getPlatformView(adUnitId: String) = plugins.asSequence()
        .mapNotNull { it as? AdWithView }
        .mapNotNull { it.getPlatformView(adUnitId) }
        .firstOrNull()


    companion object {
        internal const val CHANNEL_MAIN = "wortise"
    }
}
