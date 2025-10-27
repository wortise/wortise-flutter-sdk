package com.wortise.ads.flutter.natives

import com.wortise.ads.natives.NativeAdView

interface NativeAdViewFactory {
    fun createNativeAdView(): NativeAdView
}