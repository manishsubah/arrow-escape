import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:arrow_puzzle/app_info.dart';
import 'package:arrow_puzzle/data/repositories/settings_repository.dart';
import 'package:arrow_puzzle/data/services/ad_service.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_panel.dart';
import 'package:arrow_puzzle/ui/core/widgets/sticker_text.dart';
import 'package:arrow_puzzle/ui/features/legal/legal_content.dart';
import 'package:arrow_puzzle/ui/features/legal/views/legal_screen.dart';
import 'package:arrow_puzzle/ui/features/settings/view_models/settings_view_model.dart';

/// Settings screen with sound/haptics toggles plus legal & support links.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settingsRepository,
    required this.adService,
  });

  final SettingsRepository settingsRepository;
  final AdService adService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel(
      settingsRepository: widget.settingsRepository,
      adService: widget.adService,
    );
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    ChunkyButton(
                      color: Skeuo.orange,
                      radius: 18,
                      lipDepth: 5,
                      padding: const EdgeInsets.all(10),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_rounded, size: 22),
                    ),
                    const SizedBox(width: 16),
                    const StickerText('Settings'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Settings list
              Expanded(
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    if (_viewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Skeuo.green),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.volume_up_rounded,
                            iconColor: Skeuo.blue,
                            title: 'Sound Effects',
                            subtitle: 'Play sounds when tapping arrows',
                            value: _viewModel.soundEnabled,
                            onChanged: (_) => _viewModel.toggleSound(),
                          ),
                          const SizedBox(height: 14),
                          _SettingsTile(
                            icon: Icons.vibration_rounded,
                            iconColor: Skeuo.purple,
                            title: 'Haptic Feedback',
                            subtitle: 'Vibrate on arrow interactions',
                            value: _viewModel.hapticsEnabled,
                            onChanged: (_) => _viewModel.toggleHaptics(),
                          ),
                          const SizedBox(height: 28),
                          _buildLegalSection(context),
                          const SizedBox(height: 28),
                          _buildAboutCard(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return SkeuoPanel(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: Column(
        children: [
          _LinkTile(
            icon: Icons.privacy_tip_rounded,
            iconColor: Skeuo.green,
            title: 'Privacy Policy',
            onTap: () => _openDocument(LegalContent.privacyPolicy),
          ),
          _LinkTile(
            icon: Icons.gavel_rounded,
            iconColor: Skeuo.orange,
            title: 'Terms of Service',
            onTap: () => _openDocument(LegalContent.termsOfService),
          ),
          if (_viewModel.privacyOptionsRequired)
            _LinkTile(
              icon: Icons.tune_rounded,
              iconColor: Skeuo.purple,
              title: 'Privacy Choices',
              subtitle: 'Manage ad personalization consent',
              onTap: _viewModel.openPrivacyChoices,
            ),
          _LinkTile(
            icon: Icons.mail_rounded,
            iconColor: Skeuo.blue,
            title: 'Contact Support',
            subtitle: AppInfo.supportEmail,
            onTap: _copySupportEmail,
          ),
        ],
      ),
    );
  }

  void _openDocument(LegalDocument document) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LegalScreen(document: document)));
  }

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(const ClipboardData(text: AppInfo.supportEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support email copied to clipboard')),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return SkeuoPanel(
      radius: 22,
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        children: [
          const _CandyBadge(
            icon: Icons.navigation_rounded,
            color: Skeuo.blue,
            size: 64,
          ),
          const SizedBox(height: 16),
          StickerText(
            AppInfo.appName,
            style: Theme.of(context).textTheme.titleLarge,
            outlineWidth: 4,
          ),
          const SizedBox(height: 6),
          Text(
            'Version ${AppInfo.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Skeuo.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // Required attribution for bundled open-source packages; kept
          // low-key here rather than as a full row in the legal section.
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: AppInfo.appName,
              applicationVersion: AppInfo.version,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Skeuo.inkSoft,
              textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
            child: const Text('Open-source licenses'),
          ),
        ],
      ),
    );
  }
}

/// A raised card with a candy icon badge and a toggle.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SkeuoPanel(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _CandyBadge(icon: icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Skeuo.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Skeuo.inkSoft),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// A tappable row inside the legal section: badge, label, chevron.
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Transparent Material so the ink splash paints above the panel surface.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _CandyBadge(icon: icon, color: iconColor, size: 36),
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
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: Skeuo.inkSoft,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Skeuo.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small glossy molded chip holding an icon — the raised-surface recipe at
/// badge scale.
class _CandyBadge extends StatelessWidget {
  const _CandyBadge({required this.icon, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.32);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.faceOf(color), color],
        ),
        border: Border.all(color: Skeuo.lipOf(color), width: 2),
        boxShadow: Skeuo.lift(y: 4, blur: 8, alpha: 0.18),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        gradient: Skeuo.gloss(alpha: 0.42, stop: 0.5),
      ),
      child: Icon(
        icon,
        color: Skeuo.onCandy,
        size: size * 0.5,
        shadows: Skeuo.embossedText,
      ),
    );
  }
}
