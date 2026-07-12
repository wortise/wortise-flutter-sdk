package com.wortise.ads.flutter.extensions

import com.wortise.ads.AdValue

fun AdValue.toMap() = mapOf(
    "currency"  to currency,
    "precision" to precision?.name,
    "value"     to value
)
