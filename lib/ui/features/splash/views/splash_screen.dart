import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:arrow_puzzle/data/repositories/settings_repository.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// Animated splash screen with logo reveal.
/// After a short delay, goes to onboarding until the current terms are
/// accepted, and to Home afterwards.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.settingsRepository});

  final SettingsRepository settingsRepository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final results = await Future.wait([
      widget.settingsRepository.hasAcceptedCurrentTerms(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;
    final accepted = results.first as bool;
    Navigator.of(context)
        .pushReplacementNamed(accepted ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App icon logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Skeuo.ink.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: SvgPicture.asset(
                        'assets/icons/app_icon.svg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Arrow Escape',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap. Slide. Escape.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                          letterSpacing: 4,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
