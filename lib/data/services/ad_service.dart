import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages user consent (Google UMP) and interstitial ads using Google AdMob.
///
/// Debug/profile builds always use Google's test ad units. Release builds read
/// the real ad unit IDs from `--dart-define`:
///
/// ```
/// flutter build appbundle --release \
///   --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxx/yyy
/// flutter build ipa --release \
///   --dart-define=ADMOB_INTERSTITIAL_IOS=ca-app-pub-xxx/zzz
/// ```
///
/// If a release build has no ID configured, ads are disabled rather than
/// serving test ads (which violates AdMob policy).
class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _canRequestAds = false;

  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _releaseInterstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
  );
  static const String _releaseInterstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
  );

  static bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// The interstitial ad unit for this platform/build, or null if none.
  static String? get _adUnitId {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (!kReleaseMode) {
      return isIos ? _testInterstitialIos : _testInterstitialAndroid;
    }
    final id = isIos ? _releaseInterstitialIos : _releaseInterstitialAndroid;
    return id.isEmpty ? null : id;
  }

  /// Gathers consent (shows the UMP form where legally required, e.g. EEA/UK),
  /// then initializes the Mobile Ads SDK and preloads an ad.
  Future<void> initialize() async {
    if (!_isSupportedPlatform || _adUnitId == null) return;
    try {
      await _gatherConsent();
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      if (!_canRequestAds) return;
      await MobileAds.instance.initialize();
      _loadInterstitialAd();
    } catch (_) {
      // Ads unavailable — game continues without them
    }
  }

  Future<void> _gatherConsent() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((_) {
          if (!completer.isCompleted) completer.complete();
        });
      },
      (_) {
        // Fall back to any consent collected in a previous session.
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  /// Whether the user must be offered a way to change their ad consent
  /// (shown as "Privacy Choices" in Settings).
  Future<bool> isPrivacyOptionsRequired() async {
    if (!_isSupportedPlatform || _adUnitId == null) return false;
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Re-opens the consent form so the user can change their choices.
  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
  }

  /// Loads an interstitial ad.
  void _loadInterstitialAd() {
    final adUnitId = _adUnitId;
    if (!_canRequestAds || adUnitId == null) return;
    InterstitialAd.load(
      adUnitId: adUnitId,
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
