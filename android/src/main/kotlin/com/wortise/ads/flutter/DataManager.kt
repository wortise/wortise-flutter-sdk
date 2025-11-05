package com.wortise.ads.flutter

import android.content.Context
import com.wortise.ads.data.DataManager
import com.wortise.ads.flutter.WortiseFlutterPlugin.Companion.CHANNEL_MAIN
import com.wortise.ads.user.UserGender
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class DataManager : FlutterPlugin, MethodCallHandler {

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

            "addEmail"  -> addEmail(call, result)

            "getAge"    -> result.success(DataManager.getAge(context))

            "getEmails" -> result.success(DataManager.getEmails(context))

            "getGender" -> getGender(call, result)

            "setAge"    -> setAge(call, result)

            "setEmails" -> setEmails(call, result)

            "setGender" -> setGender(call, result)

            else        -> result.notImplemented()
        }
    }


    private fun addEmail(call: MethodCall, result: Result) {
        val email = call.argument<String>("email")

        requireNotNull(email)

        DataManager.addEmail(context, email)

        result.success(null)
    }

    private fun getGender(call: MethodCall, result: Result) {
        val gender = DataManager.getGender(context)
            ?.name
            ?.lowercase()

        result.success(gender)
    }

    private fun setAge(call: MethodCall, result: Result) {
        val age = call.argument<Int>("age")

        requireNotNull(age)

        DataManager.setAge(context, age)

        result.success(null)
    }

    private fun setEmails(call: MethodCall, result: Result) {
        val list = call.argument<List<String>>("list")

        DataManager.setEmails(context, list)

        result.success(null)
    }

    private fun setGender(call: MethodCall, result: Result) {
        val name = call.argument<String>("gender")

        val gender = name?.uppercase()?.let { UserGender.valueOf(it) }

        DataManager.setGender(context, gender)

        result.success(null)
    }


    companion object {
        const val CHANNEL_ID = "${CHANNEL_MAIN}/dataManager"
    }
}
