import 'package:flutter/material.dart';

import '../../../../data/repositories/level_repository.dart';
import '../view_models/level_selection_view_model.dart';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
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
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B)
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF64748B)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: const Color(0xFFF8FAFC),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Mission Map',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
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
                        child: CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                        ),
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
                      color: const Color(0xFF64748B),
                    ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _viewModel.completionPercent / 100,
                  minHeight: 6,
                  backgroundColor:
                      const Color(0xFF64748B).withValues(alpha: 0.3),
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${_viewModel.totalStars} / ${_viewModel.totalLevels}',
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
          mainAxisSpacing: 12,
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
    Color bgColor;
    Color borderColor;
    Color textColor;
    Widget? icon;

    if (isCompleted) {
      bgColor = const Color(0xFF06B6D4).withValues(alpha: 0.2);
      borderColor = const Color(0xFF06B6D4);
      textColor = const Color(0xFF06B6D4);
      icon = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFF59E0B),
            size: 10,
          );
        }),
      );
    } else if (isUnlocked) {
      bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.15);
      borderColor = const Color(0xFF3B82F6);
      textColor = const Color(0xFFF8FAFC);
    } else {
      bgColor = const Color(0xFF1E293B).withValues(alpha: 0.5);
      borderColor = const Color(0xFF64748B).withValues(alpha: 0.3);
      textColor = const Color(0xFF64748B).withValues(alpha: 0.5);
      icon = Icon(Icons.lock_rounded,
          color: const Color(0xFF64748B).withValues(alpha: 0.4), size: 14);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isUnlocked && !isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$levelId',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (icon != null) ...[
              const SizedBox(height: 2),
              icon,
            ],
          ],
        ),
      ),
    );
  }
}
