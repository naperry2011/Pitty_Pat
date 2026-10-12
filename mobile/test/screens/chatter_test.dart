import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/game/personalities.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/test_helpers.dart';

// Always rolls 0: every chance-based line fires and picks the first option.
class _Always implements Random {
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

late SettingsStore _settings;
late ProfileStore _profile;

Future<void> _stores([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  _settings = SettingsStore(p);
  _profile = ProfileStore(p, now: () => DateTime(2026, 10, 11));
}

Widget _host(Widget home) => SettingsScope(
      store: _settings,
      child: ProfileScope(store: _profile, child: MaterialApp(home: home)),
    );

// Rosie on her turn, holding a 5 and a 9 against a 5: playing leaves her one card.
GameController _rosieAboutToPlay() => GameController(
      random: MaxRandom(),
      initialState: makeState(
        currentPlayerIndex: 1,
        deck: [card(Rank.king, Suit.clubs, faceUp: false), card(Rank.nine, Suit.hearts, faceUp: false)],
        players: [
          Player(id: 'player1', name: 'Player', hand: [card(Rank.two, Suit.spades)], isAI: false),
          Player(
            id: 'ai1',
            name: 'Rosie',
            hand: [card(Rank.five, Suit.clubs), card(Rank.nine, Suit.clubs)],
            isAI: true,
          ),
        ],
      ),
    );

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  testWidgets('an opponent speaks after a play, and the bubble clears', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await _stores();
    await tester.pumpWidget(_host(GameScreen(
      difficulty: AIDifficulty.easy,
      matchTarget: 5,
      controller: _rosieAboutToPlay(),
      chatRandom: _Always(),
    )));

    await tester.pump(const Duration(milliseconds: 1300)); // Rosie plays her 5
    await tester.pump(const Duration(milliseconds: 300));
    final line = personalityByName('Rosie').lines[Moment.lastCard]!.first;
    expect(find.text(line), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(line), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('turning chatter off silences opponents', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await _stores({'chatter': false});
    await tester.pumpWidget(_host(GameScreen(
      difficulty: AIDifficulty.easy,
      matchTarget: 5,
      controller: _rosieAboutToPlay(),
      chatRandom: _Always(),
    )));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(personalityByName('Rosie').lines[Moment.lastCard]!.first), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the tutorial seats Rosie and names her in the hints', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await _stores();
    await tester.pumpWidget(_host(const GameScreen.tutorial()));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('^Rosie, 3 cards')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
