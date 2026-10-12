import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/daily_screen.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/screens/home_screen.dart';
import 'package:pitty_pat/screens/locker_screen.dart';
import 'package:pitty_pat/screens/pass_play_setup_screen.dart';
import 'package:pitty_pat/screens/settings_sheet.dart';
import 'package:pitty_pat/screens/setup_screen.dart';
import 'package:pitty_pat/screens/stats_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Every screen must lay out without overflow on a small phone with the
// system font size turned up (Android accessibility settings).
final _screens = <String, Widget Function()>{
  'home': () => const HomeScreen(),
  'setup': () => const SetupScreen(),
  'daily': () => const DailyScreen(),
  'stats': () => const StatsScreen(),
  'locker': () => const LockerScreen(),
  'settings': () => const Scaffold(body: SettingsSheet()),
  'game 1v1': () => const GameScreen(difficulty: AIDifficulty.easy, matchTarget: 10),
  'game 4p': () => const GameScreen(difficulty: AIDifficulty.hard, matchTarget: 10, opponents: 3),
  'tutorial': () => const GameScreen.tutorial(),
  'pass setup': () => const PassPlaySetupScreen(),
  'pass cover 4p': () => const GameScreen.passAndPlay(
        playerNames: ['Bartholomew', 'Jay', 'Sam', 'Alexandria'],
        matchTarget: 10,
      ),
};

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  for (final scale in [1.3, 2.0]) {
    for (final size in [const Size(360, 640), const Size(411, 914)]) {
      for (final entry in _screens.entries) {
        testWidgets('${entry.key} fits ${size.width.toInt()}x${size.height.toInt()} at ${scale}x text',
            (tester) async {
          tester.view.physicalSize = size * 3;
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({'tutorialDone': true});
          final p = await SharedPreferences.getInstance();

          await tester.pumpWidget(SettingsScope(
            store: SettingsStore(p),
            child: ProfileScope(
              store: ProfileStore(p, now: () => DateTime(2026, 10, 11)),
              child: MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: entry.value(),
              ),
            ),
          ));
          await tester.pump(const Duration(seconds: 1));
          // Any overflow is reported by the framework and fails the test.
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
