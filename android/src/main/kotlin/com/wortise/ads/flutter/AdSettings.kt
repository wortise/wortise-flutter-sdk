package com.wortise.ads.flutter

import android.content.Context
import com.wortise.ads.AdContentRating
import com.wortise.ads.AdSettings
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AdSettings : FlutterPlugin, MethodCallHandler {

    private lateinit var channel : MethodChannel

    private lateinit var context: Context


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_ID)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {

            "getAssetKey"           -> result.success(AdSettings.getAssetKey(context))

            "getMaxAdContentRating" -> getMaxAdContentRating(call, result)

            "getUserId"             -> result.success(AdSettings.getUserId(context))

            "isChildDirected"       -> result.success(AdSettings.isChildDirected(context))

            "isTestEnabled"         -> result.success(AdSettings.testEnabled)

            "setChildDirected"      -> setChildDirected(call, result)

            "setMaxAdContentRating" -> setMaxAdContentRating(call, result)

            "setTestEnabled"        -> setTestEnabled(call, result)

            "setUserId"             -> setUserId(call, result)

            else                    -> result.notImplemented()
        }
    }


    private fun getMaxAdContentRating(call: MethodCall, result: Result) {
        val rating = AdSettings.getMaxAdContentRating(context)
            ?.name
            ?.lowercase()

        result.success(rating)
    }

    private fun setChildDirected(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled")

        requireNotNull(enabled)

        AdSettings.setChildDirected(context, enabled)

        result.success(null)
    }

    private fun setMaxAdContentRating(call: MethodCall, result: Result) {
        val name = call.argument<String>("rating")

        val rating = name?.uppercase()?.let { AdContentRating.valueOf(it) }

        AdSettings.setMaxAdContentRating(context, rating)

        result.success(null)
    }

    private fun setTestEnabled(call: MethodCall, result: Result) {
        val enabled = requireNotNull(
            call.argument<Boolean>("enabled")
        )

        AdSettings.testEnabled = enabled

        result.success(null)
    }

    private fun setUserId(call: MethodCall, result: Result) {
        val userId = call.argument<String>("userId")

        AdSettings.setUserId(context, userId)

        result.success(null)
    }


    companion object {
        const val CHANNEL_ID = "${CHANNEL_MAIN}/adSettings"
    }
}
