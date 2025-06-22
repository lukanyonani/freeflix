import 'dart:io';

class AdsManager {
  static bool testAd = false;

  static String get rewardedAdID {
    if (testAd == true) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isAndroid) {
      return "ca-app-pub-8279863701405798/4287289552";
    } else {
      throw UnsupportedError("Un Supported");
    }
  }

  static String get bannerAdID {
    if (testAd == true) {
      return "ca-app-pub-3940256099942544/6300978111";
    } else if (Platform.isAndroid) {
      return "ca-app-pub-8279863701405798/4252179278";
    } else {
      throw UnsupportedError("Un Supported");
    }
  }
}
