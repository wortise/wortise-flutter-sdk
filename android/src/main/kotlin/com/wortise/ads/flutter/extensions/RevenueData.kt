package com.wortise.ads.flutter.extensions

import com.wortise.ads.RevenueData

fun RevenueData.toMap() = mapOf(
    "revenue" to revenue.toMap(),
    "source"  to source
)
