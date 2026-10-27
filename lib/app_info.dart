/// Static app metadata shown in Settings and the legal pages.
///
/// Fill in [developerName] and [supportEmail] before publishing — they appear
/// in the Privacy Policy and Terms of Service.
class AppInfo {
  AppInfo._();

  static const String appName = 'Arrow Escape';

  /// Keep in sync with `version:` in pubspec.yaml.
  static const String version = '1.0.0';

  // TODO(release): replace with your legal name/company and a real inbox.
  static const String developerName = 'The Arrow Escape Team';
  static const String supportEmail = 'support@example.com';

  /// Date the legal documents were last revised.
  static const String legalLastUpdated = 'October 27, 2026';
}
