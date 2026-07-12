import 'package:flutter/foundation.dart';

const supportedPlatforms = [
  TargetPlatform.android,
  TargetPlatform.iOS,
];

bool get isSupportedPlatform =>
    !kIsWeb && supportedPlatforms.contains(defaultTargetPlatform);
