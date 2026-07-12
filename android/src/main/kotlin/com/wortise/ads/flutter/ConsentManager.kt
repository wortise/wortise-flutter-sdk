package com.wortise.ads.flutter

import android.app.Activity
import android.content.Context
import com.wortise.ads.consent.ConsentManager
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ConsentManager : ActivityAware, FlutterPlugin, MethodCallHandler {

    private var activity: Activity? = null

    private lateinit var channel : MethodChannel

    private lateinit var context: Context


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
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

            "canCollectData"            -> result.success(ConsentManager.canCollectData(context))

            "canRequestPersonalizedAds" -> result.success(ConsentManager.canRequestPersonalizedAds(context))

            "exists"                    -> result.success(ConsentManager.exists(context))

            "request"                   -> request(call, result)

            "requestIfRequired"         -> requestIfRequired(call, result)

            else                        -> result.notImplemented()
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }


    private fun request(call: MethodCall, result: Result) {
        val activity = requireNotNull(activity)

        ConsentManager.request(activity) {
            result.success(it)
        }
    }

    private fun requestIfRequired(call: MethodCall, result: Result) {
        val activity = requireNotNull(activity)

        ConsentManager.requestIfRequired(activity) {
            result.success(it)
        }
    }


    companion object {
        private const val CHANNEL_ID = "${CHANNEL_MAIN}/consentManager"
    }
}
