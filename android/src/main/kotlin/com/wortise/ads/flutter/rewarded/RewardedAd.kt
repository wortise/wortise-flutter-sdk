package com.wortise.ads.flutter.rewarded

import android.app.Activity
import android.content.Context
import com.wortise.ads.AdError
import com.wortise.ads.RevenueData
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.flutter.extensions.toMap
import com.wortise.ads.rewarded.RewardedAd
import com.wortise.ads.rewarded.models.Reward
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class RewardedAd : ActivityAware, FlutterPlugin, MethodCallHandler {

    private var activity: Activity? = null

    private lateinit var binding: FlutterPlugin.FlutterPluginBinding

    private lateinit var channel : MethodChannel

    private lateinit var context: Context

    private val instances = mutableMapOf<String, RewardedAd>()


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


    private fun createInstance(adUnitId: String): RewardedAd {
        val activity = requireNotNull(activity)

        val adChannel = MethodChannel(binding.binaryMessenger, "${CHANNEL_ID}_$adUnitId")

        return RewardedAd(activity, adUnitId).also {

            it.listener = RewardedAdListener(adChannel)

            instances[adUnitId] = it
        }
    }

    private fun destroy(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        instances.remove(adUnitId)?.destroy()

        result.success(null)
    }

    private fun isAvailable(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val isAvailable = instances[adUnitId]?.isAvailable == true

        result.success(isAvailable)
    }

    private fun isDestroyed(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val isDestroyed = instances[adUnitId]?.isDestroyed == true

        result.success(isDestroyed)
    }

    private fun loadAd(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val rewardedAd = instances[adUnitId] ?: createInstance(adUnitId)

        rewardedAd.loadAd()

        result.success(null)
    }

    private fun showAd(call: MethodCall, result: Result) {
        val adUnitId = call.argument<String>("adUnitId")

        requireNotNull(adUnitId)

        val rewardedAd = instances[adUnitId]

        if (rewardedAd?.isAvailable != true) {
            result.success(false)
            return
        }

        rewardedAd.showAd()

        result.success(true)
    }


    private class RewardedAdListener(private val channel: MethodChannel) : RewardedAd.Listener {

        override fun onRewardedClicked(ad: RewardedAd) {
            channel.invokeMethod("clicked", null)
        }

        override fun onRewardedCompleted(ad: RewardedAd, reward: Reward) {
            val values = mapOf(
                "amount"  to reward.amount,
                "label"   to reward.label,
                "success" to reward.success
            )

            channel.invokeMethod("completed", values)
        }

        override fun onRewardedDismissed(ad: RewardedAd) {
            channel.invokeMethod("dismissed", null)
        }

        override fun onRewardedFailedToLoad(ad: RewardedAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToLoad", values)
        }

        override fun onRewardedFailedToShow(ad: RewardedAd, error: AdError) {
            val values = mapOf("error" to error.name)

            channel.invokeMethod("failedToShow", values)
        }

        override fun onRewardedImpression(ad: RewardedAd) {
            channel.invokeMethod("impression", null)
        }

        override fun onRewardedLoaded(ad: RewardedAd) {
            channel.invokeMethod("loaded", null)
        }

        override fun onRewardedRevenuePaid(ad: RewardedAd, data: RevenueData) {
            channel.invokeMethod("revenuePaid", data.toMap())
        }

        override fun onRewardedShown(ad: RewardedAd) {
            channel.invokeMethod("shown", null)
        }
    }


    companion object {
        private const val CHANNEL_ID = "${CHANNEL_MAIN}/rewardedAd"
    }
}