import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/main.dart';
import 'package:pitty_pat/profile/player_profile.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/profile/progression.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/test_helpers.dart';

late SettingsStore _settings;
late ProfileStore _profile;

Future<void> _stores([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  _settings = SettingsStore(p);
  _profile = ProfileStore(p, now: () => DateTime(2026, 10, 11));
}

void _size(WidgetTester tester, Size logical) {
  tester.view.physicalSize = logical * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Widget _host(Widget home) => SettingsScope(
      store: _settings,
      child: ProfileScope(store: _profile, child: MaterialApp(home: home)),
    );

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  testWidgets('setup saves 3 opponents and the game seats all of them', (tester) async {
    _size(tester, const Size(411, 914));
    await _stores({'tutorialDone': true});
    await tester.pumpWidget(PittyPatApp(store: _settings, profile: _profile, theme: ThemeData()));
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('4-player table'));
    await tester.tap(find.text('4-player table'));
    await tester.pump();
    await tester.ensureVisible(find.text('Play!'));
    await tester.tap(find.text('Play!'));
    await tester.pumpAndSettle();

    expect(_settings.settings.opponents, 3);
    // Chill (the default) seats the Chill personalities.
    for (final name in ['Rosie', 'Pops', 'Lulu']) {
      expect(find.bySemanticsLabel(RegExp('^$name, 5 cards')), findsOneWidget);
    }
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
  });

  for (final count in [1, 2, 3]) {
    testWidgets('a $count-opponent table fits a small 360x640 phone', (tester) async {
      _size(tester, const Size(360, 640));
      await _stores();
      await tester.pumpWidget(_host(GameScreen(
        difficulty: AIDifficulty.easy,
        matchTarget: 10,
        opponents: count,
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('round banners name the winning opponent', (tester) async {
    _size(tester, const Size(411, 914));
    await _stores();
    final controller = GameController(
      random: MaxRandom(),
      initialState: makeState(
        currentPlayerIndex: 2,
        deck: [card(Rank.king, Suit.clubs, faceUp: false)],
        players: [
          Player(id: 'player1', name: 'Player', hand: [card(Rank.two, Suit.spades)], isAI: false),
          Player(id: 'ai1', name: 'CPU 1', hand: [card(Rank.nine, Suit.clubs)], isAI: true),
          Player(id: 'ai2', name: 'CPU 2', hand: [card(Rank.five, Suit.clubs)], isAI: true),
        ],
      ),
    );
    await tester.pumpWidget(_host(GameScreen(
      difficulty: AIDifficulty.easy,
      matchTarget: 5,
      opponents: 2,
      controller: controller,
    )));
    await tester.pump(const Duration(milliseconds: 1300)); // CPU 2 plays its last card
    await tester.pumpAndSettle();
    expect(find.text('CPU 2 wins the round!'), findsOneWidget);
  });

  test('bigger tables pay more, and a 4-player win unlocks Table Boss', () {
    const base = MatchOutcome(
      difficulty: AIDifficulty.medium,
      matchTarget: 5,
      won: true,
      roundsWon: 5,
      roundsLost: 3,
    );
    const full = MatchOutcome(
      difficulty: AIDifficulty.medium,
      matchTarget: 5,
      won: true,
      roundsWon: 5,
      roundsLost: 3,
      opponents: 3,
    );
    expect(matchReward(full).coins, matchReward(base).coins * 2);
    final (_, s) = applyMatch(const PlayerProfile(), full, DateTime(2026, 10, 11));
    expect(s!.unlocked.map((a) => a.id), contains('table_boss'));
  });
}
