enum AdSizeType {
  anchored,
  inline,
  normal
}

class AdSize {
  static const AdSize HEIGHT_50 = AdSize._(height: 50);

  static const AdSize HEIGHT_90 = AdSize._(height: 90);

  static const AdSize HEIGHT_250 = AdSize._(height: 250);

  static const AdSize HEIGHT_280 = AdSize._(height: 280);

  static const AdSize MATCH_VIEW = AdSize._();


  final int height;
  
  final AdSizeType type;

  final int width;


  const AdSize._({
    this.height = -1,
    this.type = AdSizeType.normal,
    this.width = -1
  });


  const AdSize({int width = -1, int height = -1}) : this._(
    height: height,
    width: width
  );

  const AdSize.getAnchoredAdaptiveBannerAdSize(int width) : this._(
    type: AdSizeType.anchored,
    width: width
  );

  const AdSize.getInlineAdaptiveBannerAdSize(int width, int maxHeight) : this._(
    height: maxHeight,
    type: AdSizeType.inline,
    width: width
  );

  
  Map<String, dynamic> get toMap => {
    "height": this.height,
    "type": this.type.name,
    "width": this.width
  };
}
