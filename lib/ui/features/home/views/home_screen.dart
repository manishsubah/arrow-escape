import 'dart:math';

import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';

/// Home screen with game title, play button, and settings access.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              ..._buildFloatingArrows(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Bouncy logo badge
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: child,
                      ),
                      child: _buildLogo(),
                    ),
                    const SizedBox(height: 28),
                    _buildTitle(context),
                    const SizedBox(height: 10),
                    Text(
                      'Tap • Slide • Escape',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Skeuo.inkSoft,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                    ),
                    const Spacer(flex: 2),
                    // Play button
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: ChunkyButton(
                        color: Skeuo.green,
                        width: 240,
                        radius: 30,
                        lipDepth: 9,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        onTap: () =>
                            Navigator.of(context).pushNamed('/levels'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 32),
                            const SizedBox(width: 8),
                            Text(
                              'PLAY',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Skeuo.onCandy,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Settings button
              Positioned(
                top: 12,
                right: 16,
                child: ChunkyButton(
                  color: Skeuo.orange,
                  radius: 18,
                  lipDepth: 6,
                  padding: const EdgeInsets.all(12),
                  onTap: () => Navigator.of(context).pushNamed('/settings'),
                  child: const Icon(Icons.settings_rounded, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.lighten(Skeuo.blue, 0.25), Skeuo.blue],
        ),
        border: Border.all(color: Skeuo.darken(Skeuo.blue, 0.30), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: const Icon(
        Icons.navigation_rounded,
        size: 56,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final style = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        );
    return Stack(
      children: [
        // Outline / sticker edge
        Text(
          'Arrow Escape',
          style: style?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.white,
          ),
        ),
        Text('Arrow Escape', style: style?.copyWith(color: Skeuo.ink)),
      ],
    );
  }

  /// Builds decorative floating candy arrows in the background.
  List<Widget> _buildFloatingArrows() {
    final random = Random(42);
    const arrowIcons = [
      Icons.arrow_upward_rounded,
      Icons.arrow_downward_rounded,
      Icons.arrow_back_rounded,
      Icons.arrow_forward_rounded,
    ];
    const colors = [
      Skeuo.blue,
      Skeuo.green,
      Skeuo.red,
      Skeuo.purple,
      Skeuo.orange,
    ];

    return List.generate(12, (i) {
      final top = random.nextDouble() * 0.85;
      final left = random.nextDouble() * 0.88;
      final size = 22.0 + random.nextDouble() * 22;

      return Positioned(
        top: MediaQuery.of(context).size.height * top,
        left: MediaQuery.of(context).size.width * left,
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            final offset = _floatAnimation.value * (i.isEven ? 1.0 : -1.0);
            return Transform.translate(
              offset: Offset(offset * 0.5, offset),
              child: child,
            );
          },
          child: Icon(
            arrowIcons[i % arrowIcons.length],
            size: size,
            color: colors[i % colors.length].withValues(alpha: 0.28),
          ),
        ),
      );
    });
  }
}
