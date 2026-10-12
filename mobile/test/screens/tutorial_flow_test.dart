import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/main.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SettingsStore _settings;
late ProfileStore _profile;

Future<void> _boot(WidgetTester tester, [Map<String, Object> prefs = const {}]) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  _settings = SettingsStore(p);
  _profile = ProfileStore(p, now: () => DateTime(2026, 10, 11));
  await tester.pumpWidget(PittyPatApp(store: _settings, profile: _profile, theme: ThemeData()));
}

Future<void> _tapCardTwice(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label));
  await tester.pump();
  await tester.tap(find.bySemanticsLabel(label));
  await tester.pump();
}

// Lets the end-of-turn and computer timers (and card flights) run.
Future<void> _letComputerPlay(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  testWidgets('first Play opens the tutorial with coaching', (tester) async {
    await _boot(tester);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.isTutorial, isTrue);
    expect(find.textContaining('Match the rank of the top card'), findsOneWidget);
    expect(find.text('Skip tutorial'), findsOneWidget);
  });

  testWidgets('skipping marks it done and goes to setup', (tester) async {
    await _boot(tester);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip tutorial'));
    await tester.pumpAndSettle();

    expect(find.text('Game Setup'), findsOneWidget);
    expect(_settings.settings.tutorialDone, isTrue);
  });

  testWidgets('finishing the scripted hand ends ready-to-play, with nothing recorded', (tester) async {
    await _boot(tester);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    await _tapCardTwice(tester, '7 of spades');
    await _letComputerPlay(tester);
    expect(find.textContaining('No queen'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Draw pile')));
    await tester.pump();
    await _letComputerPlay(tester);

    await _tapCardTwice(tester, '9 of clubs');
    await _letComputerPlay(tester);
    await _tapCardTwice(tester, '3 of diamonds');
    await tester.pumpAndSettle();

    expect(find.text("You're ready to play!"), findsOneWidget);
    expect(_profile.profile.statsFor(AIDifficulty.easy).roundsPlayed, 0);
    expect(_profile.profile.coins, 0);

    await tester.tap(find.text("Let's play!"));
    await tester.pumpAndSettle();
    expect(find.text('Game Setup'), findsOneWidget);
    expect(_settings.settings.tutorialDone, isTrue);
  });

  testWidgets('returning players go straight to setup', (tester) async {
    await _boot(tester, {'tutorialDone': true});
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(find.text('Game Setup'), findsOneWidget);
  });

  testWidgets('the tutorial can be replayed from How to play', (tester) async {
    await _boot(tester, {'tutorialDone': true});
    await tester.tap(find.bySemanticsLabel('How to play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play the tutorial'));
    await tester.pumpAndSettle();
    expect(tester.widget<GameScreen>(find.byType(GameScreen)).isTutorial, isTrue);
  });
}
