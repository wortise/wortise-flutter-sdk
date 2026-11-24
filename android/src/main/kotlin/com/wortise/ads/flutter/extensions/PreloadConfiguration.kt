package com.wortise.ads.flutter.extensions

import com.wortise.ads.preload.PreloadConfiguration
import io.flutter.plugin.common.MethodCall

fun MethodCall.getPreloadConfiguration() = PreloadConfiguration(
    bufferSize = argument<Int>("bufferSize") ?: 1,
    parameters = getRequestParameters()
)
