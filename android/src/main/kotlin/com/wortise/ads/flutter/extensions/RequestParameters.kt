package com.wortise.ads.flutter.extensions

import com.wortise.ads.CollapsiblePosition
import com.wortise.ads.RequestParameters
import io.flutter.plugin.common.MethodCall

fun getRequestParameters(args: Map<*, *>?): RequestParameters {
    val params = args?.get("requestParameters") as? Map<*, *>

    val agent = params?.get("agent") as? String

    val collapsible = CollapsiblePosition.fromValue(
        params?.get("collapsible") as? String
    )

    return RequestParameters(
        agent       = agent,
        collapsible = collapsible
    )
}

fun MethodCall.getRequestParameters(): RequestParameters =
    getRequestParameters(arguments as? Map<*, *>)
