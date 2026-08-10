import 'dart:math';

import 'package:flutter/material.dart';

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background floating arrows decoration
              ..._buildFloatingArrows(),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Logo
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          size: 48,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Arrow Escape',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap. Slide. Escape.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                            letterSpacing: 3,
                          ),
                    ),
                    const Spacer(flex: 2),
                    // Play button
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: SizedBox(
                        width: 220,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/levels');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow_rounded, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Play',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFFF8FAFC),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Settings button
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF64748B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    color: const Color(0xFFF8FAFC),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds decorative floating arrow icons in the background.
  List<Widget> _buildFloatingArrows() {
    final random = Random(42); // Fixed seed for consistent layout
    const arrowIcons = [
      Icons.arrow_upward_rounded,
      Icons.arrow_downward_rounded,
      Icons.arrow_back_rounded,
      Icons.arrow_forward_rounded,
    ];
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF06B6D4),
      Color(0xFFEF4444),
      Color(0xFF22C55E),
      Color(0xFFF59E0B),
    ];

    return List.generate(12, (i) {
      final top = random.nextDouble() * 0.8;
      final left = random.nextDouble() * 0.9;
      final size = 20.0 + random.nextDouble() * 20;
      final opacity = 0.05 + random.nextDouble() * 0.08;

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
            color: colors[i % colors.length].withValues(alpha: opacity),
          ),
        ),
      );
    });
  }
}
