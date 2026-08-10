import 'package:flutter/material.dart';

import 'data/repositories/level_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/ad_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/level_service.dart';
import 'data/services/progress_service.dart';
import 'data/services/settings_service.dart';
import 'ui/core/theme.dart';
import 'ui/features/game/views/game_screen.dart';
import 'ui/features/home/views/home_screen.dart';
import 'ui/features/level_complete/views/level_complete_screen.dart';
import 'ui/features/level_failed/views/level_failed_screen.dart';
import 'ui/features/level_selection/views/level_selection_screen.dart';
import 'ui/features/settings/views/settings_screen.dart';
import 'ui/features/splash/views/splash_screen.dart';

void main() {
  runApp(const ArrowEscapeApp());
}

class ArrowEscapeApp extends StatefulWidget {
  const ArrowEscapeApp({super.key});

  @override
  State<ArrowEscapeApp> createState() => _ArrowEscapeAppState();
}

class _ArrowEscapeAppState extends State<ArrowEscapeApp> {
  // Services
  late final LevelService _levelService;
  late final ProgressService _progressService;
  late final AudioService _audioService;
  late final SettingsService _settingsService;
  late final AdService _adService;

  // Repositories
  late final LevelRepository _levelRepository;
  late final SettingsRepository _settingsRepository;

  // Settings cache
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _levelService = LevelService();
    _progressService = ProgressService();
    _audioService = AudioService();
    _settingsService = SettingsService();
    _adService = AdService();
    _adService.initialize();

    _levelRepository = LevelRepository(
      levelService: _levelService,
      progressService: _progressService,
    );
    _settingsRepository = SettingsRepository(
      settingsService: _settingsService,
      audioService: _audioService,
    );

    // Load initial settings
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsRepository.getSoundEnabled();
    _hapticsEnabled = await _settingsRepository.getHapticsEnabled();
  }

  @override
  void dispose() {
    _audioService.dispose();
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrow Escape',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name;

        if (name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const SplashScreen(),
          );
        }

        if (name == '/home') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const HomeScreen(),
          );
        }

        if (name == '/levels') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => LevelSelectionScreen(
              levelRepository: _levelRepository,
            ),
          );
        }

        if (name != null && name.startsWith('/game/')) {
          final levelId = int.tryParse(name.split('/').last.split('?').first) ?? 1;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => GameScreen(
              levelId: levelId,
              levelRepository: _levelRepository,
              audioService: _audioService,
              adService: _adService,
              hapticsEnabled: _hapticsEnabled,
            ),
          );
        }

        if (name != null && name.startsWith('/failed/')) {
          final levelId = int.tryParse(name.split('/').last.split('?').first) ?? 1;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => LevelFailedScreen(levelId: levelId),
          );
        }

        if (name != null && name.startsWith('/complete/')) {
          final uri = Uri.parse(name);
          final levelId = int.tryParse(uri.pathSegments.last) ?? 1;
          final steps = int.tryParse(uri.queryParameters['steps'] ?? '') ?? 0;
          final stars = int.tryParse(uri.queryParameters['stars'] ?? '') ?? 1;
          final bestScore = int.tryParse(uri.queryParameters['best'] ?? '') ?? steps;
          final isNewBest = uri.queryParameters['newBest'] == 'true';
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => LevelCompleteScreen(
              levelId: levelId,
              totalLevels: 100,
              steps: steps,
              stars: stars,
              bestScore: bestScore,
              isNewBest: isNewBest,
            ),
          );
        }

        if (name == '/settings') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => SettingsScreen(
              settingsRepository: _settingsRepository,
            ),
          );
        }

        // Fallback
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      },
    );
  }
}
