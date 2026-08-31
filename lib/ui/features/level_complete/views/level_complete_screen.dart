import 'dart:math';

import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_panel.dart';
import 'package:arrow_puzzle/ui/core/widgets/sticker_text.dart';

/// Celebratory screen shown after completing a level.
class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({
    super.key,
    required this.levelId,
    required this.totalLevels,
    required this.steps,
    required this.stars,
    required this.bestScore,
    this.isNewBest = false,
  });

  final int levelId;
  final int totalLevels;
  final int steps;
  final int stars;
  final int bestScore;
  final bool isNewBest;

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _starController;
  late final AnimationController _particleController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  /// One staggered pop-in per star slot.
  late final List<CurvedAnimation> _starScales;

  final List<_Confetto> _confetti = [];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5),
      ),
    );
    _entranceController.forward();

    // Stars pop in one after another, after the card has landed.
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _starScales = List.generate(3, (index) {
      final start = index * 0.2;
      return CurvedAnimation(
        parent: _starController,
        curve: Interval(start, start + 0.6, curve: Curves.elasticOut),
      );
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _starController.forward();
    });

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    final random = Random();
    const palette = [
      Skeuo.blue,
      Skeuo.green,
      Skeuo.star,
      Skeuo.red,
      Skeuo.purple,
    ];
    for (int i = 0; i < 30; i++) {
      _confetti.add(_Confetto(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.7,
        size: 4.0 + random.nextDouble() * 6,
        color: palette[random.nextInt(palette.length)],
      ));
    }
  }

  @override
  void dispose() {
    for (final scale in _starScales) {
      scale.dispose();
    }
    _entranceController.dispose();
    _starController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  bool get _hasNextLevel => widget.levelId < widget.totalLevels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    confetti: _confetti,
                    progress: _particleController.value,
                  ),
                );
              },
            ),
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StickerText(
                            'LEVEL CLEARED!',
                            color: Skeuo.green,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Level ${widget.levelId}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Skeuo.inkSoft,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, _buildStar),
                          ),
                          const SizedBox(height: 32),
                          _buildStatsCard(context),
                          const SizedBox(height: 36),
                          if (_hasNextLevel) ...[
                            ChunkyButton(
                              color: Skeuo.green,
                              width: double.infinity,
                              radius: 28,
                              lipDepth: 8,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed(
                                  '/game/${widget.levelId + 1}',
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next Level',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 24),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          ChunkyButton(
                            color: Skeuo.card,
                            foregroundColor: Skeuo.ink,
                            width: double.infinity,
                            radius: 24,
                            lipDepth: 6,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            onTap: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/levels',
                                (route) => route.settings.name == '/home',
                              );
                            },
                            child: const Text(
                              'Level Select',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ScaleTransition(
        scale: _starScales[index],
        child: _MedalStar(filled: index < widget.stars),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return SkeuoPanel(
      radius: 22,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.directions_walk_rounded,
            label: 'Steps',
            value: '${widget.steps} steps',
          ),
          const SizedBox(height: 14),
          _StatRow(
            icon: Icons.emoji_events_rounded,
            label: 'Best Score',
            value: '${widget.bestScore} steps',
          ),
          if (widget.isNewBest) ...[
            const SizedBox(height: 16),
            _buildNewBestPill(context),
          ],
        ],
      ),
    );
  }

  Widget _buildNewBestPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.faceOf(Skeuo.green), Skeuo.green],
        ),
        border: Border.all(color: Skeuo.lipOf(Skeuo.green), width: 2),
        boxShadow: Skeuo.lift(y: 3, blur: 6, alpha: 0.18),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Skeuo.gloss(alpha: 0.4, stop: 0.5),
      ),
      child: Text(
        'NEW BEST!',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Skeuo.onCandy,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              shadows: Skeuo.embossedText,
            ),
      ),
    );
  }
}

/// A gold star with a darker rim behind it, so it reads as a stamped medal
/// rather than flat clip art. Empty slots are cut into the surface instead.
class _MedalStar extends StatelessWidget {
  const _MedalStar({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          size: 56,
          color: filled
              ? Skeuo.darken(Skeuo.star, 0.35)
              : Skeuo.inkSoft.withValues(alpha: 0.35),
        ),
        Icon(
          Icons.star_rounded,
          size: 46,
          color: filled ? Skeuo.star : Skeuo.bgTop,
        ),
        if (filled)
          // Tiny specular dot: the cheapest possible "polished metal" cue.
          Positioned(
            top: 16,
            left: 18,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Skeuo.blue, size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Skeuo.inkSoft,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Skeuo.ink,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _Confetto {
  _Confetto({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
  });

  final double x;
  final double y;
  final double speed;
  final double size;
  final Color color;
}

/// Falling candy confetti: each piece is a colored disc with a highlight dot,
/// matching the gloss on every other surface in the app.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  final List<_Confetto> confetti;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final yOffset = (piece.y + progress * piece.speed) % 1.0;
      final alpha = 0.75 * (1.0 - yOffset);
      final center = Offset(piece.x * size.width, yOffset * size.height);

      canvas.drawCircle(
        center,
        piece.size,
        Paint()..color = piece.color.withValues(alpha: alpha),
      );
      canvas.drawCircle(
        center.translate(-piece.size * 0.3, -piece.size * 0.3),
        piece.size * 0.3,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
