import 'package:arrow_puzzle/app_info.dart';

/// One heading + body block within a legal document.
class LegalSection {
  const LegalSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// A titled legal document rendered by [LegalScreen].
class LegalDocument {
  const LegalDocument({required this.title, required this.sections});

  final String title;
  final List<LegalSection> sections;
}

/// Bundled legal text, so the pages work offline.
///
/// This is a starting template, not legal advice — have it reviewed for the
/// markets you publish in, and host the same text at a public URL (both app
/// stores require a Privacy Policy link on the listing).
class LegalContent {
  LegalContent._();

  static const _app = AppInfo.appName;
  static const _dev = AppInfo.developerName;
  static const _email = AppInfo.supportEmail;

  static const privacyPolicy = LegalDocument(
    title: 'Privacy Policy',
    sections: [
      LegalSection(
        'Overview',
        '$_app ("the App") is developed by $_dev ("we", "us"). This policy '
            'explains what information is handled when you use the App. '
            'Last updated: ${AppInfo.legalLastUpdated}.',
      ),
      LegalSection(
        'Information we store on your device',
        'Your game progress (completed levels, stars, best scores) and '
            'settings (sound, haptics) are saved locally on your device only. '
            'We do not operate servers, do not require an account, and do not '
            'collect your name, email, contacts, location or photos.',
      ),
      LegalSection(
        'Advertising',
        'The App shows ads served by Google AdMob. To deliver and measure ads, '
            'Google may collect device identifiers (such as the Android '
            'Advertising ID or Apple IDFA where permitted), IP address, '
            'approximate location derived from IP, and ad interaction data. '
            'Where required by law (for example in the EEA, UK and '
            'Switzerland) you will be asked for consent first, and you can '
            'change your choice at any time from Settings > Privacy Choices. '
            'See how Google uses data: https://policies.google.com/technologies/partner-sites',
      ),
      LegalSection(
        'Fonts',
        'The App may download typefaces from Google Fonts the first time it '
            'runs, which shares your IP address with Google. See '
            'https://developers.google.com/fonts/faq/privacy',
      ),
      LegalSection(
        'Children',
        'The App is not directed at children under 13 (or the equivalent '
            'minimum age in your country). We do not knowingly collect '
            'personal information from children. If you believe a child has '
            'provided personal information through ads, contact us and we '
            'will help you request its deletion.',
      ),
      LegalSection(
        'Your choices and rights',
        'You can reset the advertising ID or limit ad tracking in your '
            'device settings, and change ad consent from Settings > Privacy '
            'Choices. Uninstalling the App deletes all locally stored data. '
            'Depending on where you live (e.g. GDPR, UK GDPR, CCPA/CPRA) you '
            'may have rights to access, delete or object to processing of '
            'your data; contact us to exercise them.',
      ),
      LegalSection(
        'Security',
        'Data stored by the App stays in your device\'s private app storage. '
            'Network traffic to advertising partners is encrypted (HTTPS).',
      ),
      LegalSection(
        'Changes',
        'We may update this policy. Changes take effect when the updated '
            'version is published in the App.',
      ),
      LegalSection('Contact', 'Questions about privacy: $_email'),
    ],
  );

  static const termsOfService = LegalDocument(
    title: 'Terms of Service',
    sections: [
      LegalSection(
        'Acceptance',
        'You accept these Terms when you tick "I agree" on the welcome '
            'screen the first time you open $_app, and by continuing to play. '
            'If you do not agree, please uninstall the App. '
            'Last updated: ${AppInfo.legalLastUpdated}.',
      ),
      LegalSection(
        'License',
        '$_dev grants you a personal, non-exclusive, non-transferable, '
            'revocable license to use the App for personal, non-commercial '
            'entertainment, subject to these Terms and the rules of the app '
            'store you downloaded it from.',
      ),
      LegalSection(
        'Acceptable use',
        'You agree not to copy, modify, reverse engineer, redistribute or '
            'resell the App or its content (levels, artwork, sounds), and not '
            'to interfere with the App\'s advertising or use it for any '
            'unlawful purpose.',
      ),
      LegalSection(
        'Intellectual property',
        'The App, its puzzles, graphics, sounds and name are owned by $_dev '
            'or its licensors. Open-source components are used under their '
            'own licenses, listed under Settings > About > Open-source licenses.',
      ),
      LegalSection(
        'Ads and third parties',
        'The App is free and supported by ads from third parties such as '
            'Google AdMob. We are not responsible for the content of ads or '
            'third-party websites they link to. Your use of those services is '
            'governed by their own terms.',
      ),
      LegalSection(
        'Progress and data',
        'Game progress is stored only on your device and may be lost if you '
            'uninstall the App, clear its data or change devices. We cannot '
            'restore lost progress.',
      ),
      LegalSection(
        'Disclaimer',
        'The App is provided "as is" and "as available", without warranties '
            'of any kind, to the fullest extent permitted by law.',
      ),
      LegalSection(
        'Limitation of liability',
        'To the fullest extent permitted by law, $_dev is not liable for any '
            'indirect, incidental or consequential damages arising from your '
            'use of the App. Nothing in these Terms limits rights you have '
            'under mandatory consumer law.',
      ),
      LegalSection(
        'Termination',
        'We may update, suspend or discontinue the App at any time. Your '
            'license ends automatically if you breach these Terms.',
      ),
      LegalSection(
        'Changes',
        'We may revise these Terms. Continued use after an update means you '
            'accept the revised Terms.',
      ),
      LegalSection('Contact', 'Questions about these Terms: $_email'),
    ],
  );
}
