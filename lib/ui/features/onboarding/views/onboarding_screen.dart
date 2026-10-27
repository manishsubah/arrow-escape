import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:arrow_puzzle/data/repositories/settings_repository.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/candy_badge.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_panel.dart';
import 'package:arrow_puzzle/ui/core/widgets/sticker_text.dart';
import 'package:arrow_puzzle/ui/features/legal/legal_content.dart';
import 'package:arrow_puzzle/ui/features/legal/views/legal_screen.dart';

/// First-launch welcome: a quick how-to-play plus agreement to the Terms of
/// Service and Privacy Policy. Shown again whenever the terms version changes.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.settingsRepository,
    required this.onAccepted,
  });

  final SettingsRepository settingsRepository;

  /// Runs once the user agrees (e.g. to start ads and their consent flow).
  final VoidCallback onAccepted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _agreed = false;
  bool _saving = false;

  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _openDocument(LegalContent.termsOfService);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _openDocument(LegalContent.privacyPolicy);

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _openDocument(LegalDocument document) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LegalScreen(document: document)));
  }

  Future<void> _accept() async {
    if (!_agreed || _saving) return;
    setState(() => _saving = true);
    await widget.settingsRepository.acceptCurrentTerms();
    if (!mounted) return;
    widget.onAccepted();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      // Agreement is required before playing; back must not skip it.
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: Skeuo.lift(y: 10, blur: 22),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: SvgPicture.asset(
                              'assets/icons/app_icon.svg',
                              width: 104,
                              height: 104,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const StickerText('Welcome!'),
                        const SizedBox(height: 8),
                        Text(
                          'Free every arrow from the board.',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: Skeuo.inkSoft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SkeuoPanel(
                          radius: 22,
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          child: const Column(
                            children: [
                              _Tip(
                                icon: Icons.touch_app_rounded,
                                color: Skeuo.blue,
                                title: 'Tap to slide',
                                body:
                                    'An arrow escapes in the direction it '
                                    'points, if its path is clear.',
                              ),
                              SizedBox(height: 18),
                              _Tip(
                                icon: Icons.favorite_rounded,
                                color: Skeuo.red,
                                title: 'Mind your hearts',
                                body:
                                    'Tapping a blocked arrow costs a heart. '
                                    'You have three per level.',
                              ),
                              SizedBox(height: 18),
                              _Tip(
                                icon: Icons.star_rounded,
                                color: Skeuo.orange,
                                title: 'Earn stars',
                                body:
                                    'Clear the board in the fewest moves '
                                    'for three stars.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    children: [
                      _buildAgreement(textTheme),
                      const SizedBox(height: 16),
                      ChunkyButton(
                        color: Skeuo.green,
                        width: double.infinity,
                        radius: 28,
                        lipDepth: 8,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        enabled: _agreed && !_saving,
                        onTap: _accept,
                        child: Text(
                          "Let's Play",
                          style: textTheme.titleLarge?.copyWith(
                            color: Skeuo.onCandy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreement(TextTheme textTheme) {
    final linkStyle = TextStyle(
      color: Skeuo.ink,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _agreed,
          onChanged: (value) => setState(() => _agreed = value ?? false),
          activeColor: Skeuo.green,
          side: const BorderSide(color: Skeuo.inkSoft, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _agreed = !_agreed),
            child: Text.rich(
              TextSpan(
                style: textTheme.bodyMedium?.copyWith(
                  color: Skeuo.inkSoft,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: linkStyle,
                    recognizer: _termsTap,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: linkStyle,
                    recognizer: _privacyTap,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One how-to-play row: candy badge, bold title, short explanation.
class _Tip extends StatelessWidget {
  const _Tip({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CandyBadge(icon: icon, color: color, size: 42),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: Skeuo.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: Skeuo.inkSoft,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
