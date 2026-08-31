import 'package:flutter/material.dart';

import 'package:arrow_puzzle/data/repositories/level_repository.dart';
import 'package:arrow_puzzle/data/services/ad_service.dart';
import 'package:arrow_puzzle/data/services/audio_service.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_panel.dart';
import 'package:arrow_puzzle/ui/features/game/view_models/game_view_model.dart';
import 'package:arrow_puzzle/ui/features/game/views/widgets/puzzle_grid.dart';

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
        decoration: const BoxDecoration(gradient: Skeuo.backgroundGradient),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Skeuo.green),
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
          ChunkyButton(
            color: Skeuo.orange,
            radius: 18,
            lipDepth: 5,
            padding: const EdgeInsets.all(10),
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_rounded, size: 22),
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
                            ? Skeuo.heart
                            : Skeuo.inkSoft.withValues(alpha: 0.5),
                        size: 26,
                        shadows: isFilled ? Skeuo.embossedText : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
          SkeuoPanel(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: Skeuo.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_viewModel.totalArrows - _viewModel.remainingArrows} / ${_viewModel.totalArrows}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Skeuo.ink,
                        fontWeight: FontWeight.w700,
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
            child: _ActionButton(
              icon: Icons.lightbulb_rounded,
              label: 'Hint',
              // Pale yellow face, so the label is cocoa rather than white.
              color: Skeuo.yellow,
              foregroundColor: Skeuo.ink,
              onTap: _viewModel.isGameOver ? null : _onHintTap,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionButton(
              icon: Icons.refresh_rounded,
              label: 'Reload',
              color: Skeuo.blue,
              onTap: _viewModel.isGameOver
                  ? null
                  : () {
                      _previousHearts = GameViewModel.maxHearts;
                      _viewModel.restart();
                    },
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled chunky button for the game's bottom action bar.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.foregroundColor = Skeuo.onCandy,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(
      color: color,
      foregroundColor: foregroundColor,
      radius: 24,
      lipDepth: 6,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          // No explicit color: the label inherits the button's foreground
          // (and its disabled dimming) from ChunkyButton's DefaultTextStyle.
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
