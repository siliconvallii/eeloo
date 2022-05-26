import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final BannerAdListener bannerAdListener = BannerAdListener(
  // Called when an ad request failed.
  onAdFailedToLoad: (Ad ad, LoadAdError error) {
    // Dispose the ad here to free resources.
    ad.dispose();
  },
);

// test ads
// android: ca-app-pub-3940256099942544/6300978111
// ios: ca-app-pub-3940256099942544/2934735716

// real ads
// android: ca-app-pub-4872929876201415/8054594153
// ios: ca-app-pub-4872929876201415/6027196618

final BannerAd bannerAd = BannerAd(
  adUnitId: Platform.isAndroid
      ? 'ca-app-pub-4872929876201415/8054594153'
      : 'ca-app-pub-4872929876201415/6027196618',
  size: AdSize.banner,
  request: const AdRequest(),
  listener: bannerAdListener,
);
