import 'package:flutter/material.dart';

import '../../../../data/repositories/level_repository.dart';
import '../../../../data/services/ad_service.dart';
import '../../../../data/services/audio_service.dart';
import '../view_models/game_view_model.dart';
import 'widgets/puzzle_grid.dart';

/// The main game screen displaying the puzzle board.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.levelId,
    required this.levelRepository,
    required this.audioService,
    required this.adService,
    this.hapticsEnabled = true,
  });

  final int levelId;
  final LevelRepository levelRepository;
  final AudioService audioService;
  final AdService adService;
  final bool hapticsEnabled;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameViewModel _viewModel;
  late final AnimationController _heartShakeController;
  bool _hasNavigated = false;
  int _previousHearts = GameViewModel.maxHearts;

  // Hint state
  int? _hintArrowId;
  bool _isHintActive = false;

  @override
  void initState() {
    super.initState();
    _heartShakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _viewModel = GameViewModel(
      levelRepository: widget.levelRepository,
      audioService: widget.audioService,
      levelId: widget.levelId,
      hapticsEnabled: widget.hapticsEnabled,
    );
    _viewModel.load();
    _viewModel.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (_viewModel.hearts < _previousHearts) {
      _heartShakeController.forward(from: 0);
    }
    _previousHearts = _viewModel.hearts;

    if (_hasNavigated) return;

    // Check game over (out of hearts)
    if (_viewModel.isGameOver) {
      _hasNavigated = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/failed/${widget.levelId}',
          );
        }
      });
      return;
    }

    // Check level complete
    if (_viewModel.gameState?.isComplete == true && !_viewModel.isAnimating) {
      _hasNavigated = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        widget.adService.showInterstitialAd(
          onAdDismissed: () {
            if (!mounted) return;
            final steps = _viewModel.gameState!.moveCount;
            final stars = _viewModel.stars ?? 1;
            final bestScore = _viewModel.bestScore ?? steps;
            final isNewBest = _viewModel.isNewBest;
            Navigator.of(context).pushReplacementNamed(
              '/complete/${widget.levelId}?steps=$steps&stars=$stars&best=$bestScore&newBest=$isNewBest',
            );
          },
        );
      });
    }
  }

  void _onHintTap() {
    final hintArrow = _viewModel.getHintArrow();
    if (hintArrow == null) return;
    setState(() {
      _hintArrowId = hintArrow.id;
      _isHintActive = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hintArrowId = null;
          _isHintActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    _heartShakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                );
              }
              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PuzzleGrid(
                        gameState: _viewModel.gameState!,
                        removableArrows: _viewModel.removableArrows,
                        exitingArrow: _viewModel.exitingArrow,
                        hintArrowId: _isHintActive ? _hintArrowId : null,
                        onArrowTap: (arrow) {
                          if (_isHintActive) {
                            setState(() {
                              _hintArrowId = null;
                              _isHintActive = false;
                            });
                          }
                          _viewModel.tapArrow(arrow);
                        },
                      ),
                    ),
                  ),
                  _buildBottomBar(context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _CircleActionButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _heartShakeController,
            builder: (context, child) {
              final shake = _heartShakeController.value;
              final offset = shake < 0.5
                  ? shake * 16
                  : (1 - shake) * 16;
              return Transform.translate(
                offset: Offset(
                  offset * (shake < 0.25 || (shake > 0.5 && shake < 0.75) ? 1 : -1),
                  0,
                ),
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(GameViewModel.maxHearts, (index) {
                final isFilled = index < _viewModel.hearts;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: AnimatedScale(
                    scale: isFilled ? 1.0 : 0.75,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: isFilled ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFilled ? Icons.favorite : Icons.favorite_border,
                        color: isFilled
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF64748B),
                        size: 26,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF64748B).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.change_history_rounded,
                  size: 16,
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_viewModel.totalArrows - _viewModel.remainingArrows} / ${_viewModel.totalArrows}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFF8FAFC),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _BottomBarButton(
              icon: Icons.lightbulb_rounded,
              iconColor: const Color(0xFFF59E0B),
              label: 'Hint',
              onTap: _viewModel.isGameOver ? null : _onHintTap,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _BottomBarButton(
              icon: Icons.refresh_rounded,
              iconColor: const Color(0xFFF8FAFC),
              label: 'Reload',
              onTap: _viewModel.isGameOver ? null : () {
                _previousHearts = GameViewModel.maxHearts;
                _viewModel.restart();
              },
              filled: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF64748B).withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFF8FAFC),
          size: 20,
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  const _BottomBarButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF1E293B).withValues(alpha: isEnabled ? 0.9 : 0.4)
              : const Color(0xFF1E293B).withValues(alpha: isEnabled ? 0.6 : 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF64748B).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? iconColor
                  : iconColor.withValues(alpha: 0.3),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Color(0xFFF8FAFC)
                        .withValues(alpha: isEnabled ? 1.0 : 0.3),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
