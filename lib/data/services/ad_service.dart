import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages interstitial ads using Google AdMob.
class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  /// Test ad unit ID for interstitials (works on all platforms).
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// Initializes the Mobile Ads SDK and preloads an ad.
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await MobileAds.instance.initialize();
      _loadInterstitialAd();
    } catch (_) {
      // Ads unavailable — game continues without them
    }
  }

  /// Loads an interstitial ad.
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _testAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Shows an interstitial ad if one is loaded.
  /// Calls [onAdDismissed] when the ad is dismissed or if no ad is available.
  void showInterstitialAd({required void Function() onAdDismissed}) {
    if (!_isAdLoaded || _interstitialAd == null) {
      // No ad available, proceed immediately
      onAdDismissed();
      _loadInterstitialAd(); // Try loading for next time
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdLoaded = false;
        _interstitialAd = null;
        _loadInterstitialAd(); // Preload next ad
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAdLoaded = false;
        _interstitialAd = null;
        _loadInterstitialAd();
        onAdDismissed();
      },
    );

    _interstitialAd!.show();
  }

  /// Disposes of the current ad.
  void dispose() {
    _interstitialAd?.dispose();
  }
}
