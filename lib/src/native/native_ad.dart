import '../base_ad.dart';
import 'native_ad_manager.dart';

class NativeAd extends BaseAd {

  final String adId;


  NativeAd(this.adId);


  Future<void> destroy() async {
    await NativeAdManager.destroyAd(adId);
  }
}
