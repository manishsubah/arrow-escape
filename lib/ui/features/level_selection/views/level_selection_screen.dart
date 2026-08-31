import 'package:flutter/material.dart';

import 'package:arrow_puzzle/data/repositories/level_repository.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/core/widgets/chunky_button.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_panel.dart';
import 'package:arrow_puzzle/ui/core/widgets/skeuo_progress_bar.dart';
import 'package:arrow_puzzle/ui/core/widgets/sticker_text.dart';
import 'package:arrow_puzzle/ui/features/level_selection/view_models/level_selection_view_model.dart';

/// Grid of level tiles showing completion/unlock state.
class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({
    super.key,
    required this.levelRepository,
  });

  final LevelRepository levelRepository;

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late final LevelSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        LevelSelectionViewModel(levelRepository: widget.levelRepository);
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
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ChunkyButton(
                          color: Skeuo.orange,
                          radius: 18,
                          lipDepth: 5,
                          padding: const EdgeInsets.all(10),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const StickerText('Mission Map'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        if (_viewModel.isLoading) {
                          return const SizedBox.shrink();
                        }
                        return _buildProgressSection(context);
                      },
                    ),
                  ],
                ),
              ),
              // Level grid
              Expanded(
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    if (_viewModel.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Skeuo.green),
                      );
                    }
                    return _buildLevelGrid(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final percent = _viewModel.completionPercent.round();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completion: $percent%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Skeuo.inkSoft,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              SkeuoProgressBar(
                value: _viewModel.completionPercent / 100,
                color: Skeuo.green,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SkeuoPanel(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Skeuo.star, size: 20),
              const SizedBox(width: 6),
              Text(
                '${_viewModel.totalStars} / ${_viewModel.totalLevels * 3}',
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
    );
  }

  Widget _buildLevelGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 750 ? 10 : 5;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
        ),
        itemCount: _viewModel.totalLevels,
        itemBuilder: (context, index) {
          final levelId = index + 1;
          final isCompleted = _viewModel.isCompleted(levelId);
          final isUnlocked = _viewModel.isUnlocked(levelId);
          final stars = _viewModel.getStars(levelId);
          return _LevelTile(
            levelId: levelId,
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
            stars: stars,
            onTap: isUnlocked
                ? () {
                    Navigator.of(context).pushNamed('/game/$levelId');
                  }
                : null,
          );
        },
      ),
    );
  }
}

/// One level in the map: a chunky candy button whose face encodes its state —
/// green with earned stars when cleared, blue when playable, grey plastic with
/// a padlock while locked.
class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.levelId,
    required this.isCompleted,
    required this.isUnlocked,
    this.stars = 0,
    this.onTap,
  });

  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color face;
    final Widget? badge;

    if (isCompleted) {
      face = Skeuo.green;
      badge = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < stars ? Skeuo.star : Colors.white.withValues(alpha: 0.5),
            size: 11,
          );
        }),
      );
    } else if (isUnlocked) {
      face = Skeuo.blue;
      badge = null;
    } else {
      face = Skeuo.muted;
      badge = const Icon(Icons.lock_rounded, size: 13);
    }

    return ChunkyButton(
      color: face,
      // Locked tiles keep the padlock legible against grey plastic.
      foregroundColor: isUnlocked ? Skeuo.onCandy : Skeuo.ink,
      radius: 14,
      lipDepth: 5,
      padding: const EdgeInsets.all(2),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$levelId',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          if (badge != null) ...[
            const SizedBox(height: 1),
            badge,
          ],
        ],
      ),
    );
  }
}
