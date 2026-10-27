import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/app_info.dart';
import 'package:arrow_puzzle/data/repositories/settings_repository.dart';
import 'package:arrow_puzzle/data/services/audio_service.dart';
import 'package:arrow_puzzle/data/services/settings_service.dart';
import 'package:arrow_puzzle/ui/features/onboarding/views/onboarding_screen.dart';

/// Stands in for AudioService, whose AudioPlayer needs a native plugin.
class _SilentAudioService implements AudioService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

SettingsRepository _repository() => SettingsRepository(
  settingsService: SettingsService(),
  audioService: _SilentAudioService(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsRepository terms', () {
    test('not accepted on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await _repository().hasAcceptedCurrentTerms(), isFalse);
    });

    test('accepted after acceptCurrentTerms', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = _repository();
      await repo.acceptCurrentTerms();
      expect(await repo.hasAcceptedCurrentTerms(), isTrue);
    });

    test('asks again when an older terms version was accepted', () async {
      SharedPreferences.setMockInitialValues({
        'terms_accepted_version': AppInfo.termsVersion - 1,
      });
      expect(await _repository().hasAcceptedCurrentTerms(), isFalse);
    });
  });

  testWidgets('Let\'s Play stays disabled until the terms are agreed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = _repository();
    var acceptedCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          settingsRepository: repo,
          onAccepted: () => acceptedCalls++,
        ),
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('HOME')),
        ),
      ),
    );

    // Tapping the button before agreeing does nothing.
    await tester.tap(find.text("Let's Play"));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsNothing);
    expect(acceptedCalls, 0);
    expect(await repo.hasAcceptedCurrentTerms(), isFalse);

    // Agree, then continue.
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text("Let's Play"));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(acceptedCalls, 1);
    expect(await repo.hasAcceptedCurrentTerms(), isTrue);
  });
}
