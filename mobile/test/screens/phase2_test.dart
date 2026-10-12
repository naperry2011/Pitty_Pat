import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/cards/card_back.dart';
import 'package:pitty_pat/cosmetics/catalog.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/main.dart';
import 'package:pitty_pat/profile/daily.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/daily_screen.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/screens/locker_screen.dart';
import 'package:pitty_pat/screens/stats_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/test_helpers.dart';

final _today = DateTime(2026, 10, 11);

late SettingsStore _settings;
late ProfileStore _profile;

Future<void> _stores([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  _settings = SettingsStore(prefs);
  _profile = ProfileStore(prefs, now: () => _today);
}

String _profileJson(Map<String, Object> fields) => jsonEncode({'v': 1, ...fields});

Widget _host(Widget home) => SettingsScope(
      store: _settings,
      child: ProfileScope(store: _profile, child: MaterialApp(home: home)),
    );

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

GameController _oneFromMatchWin() => GameController(
      random: MaxRandom(),
      initialState: makeState(
        matchTarget: 3,
        deck: [card(Rank.king, Suit.clubs, faceUp: false)],
        players: [
          Player(id: 'player1', name: 'Player', hand: [card(Rank.five, Suit.spades)], isAI: false, wins: 2),
          Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
        ],
      ),
    );

Future<void> _playFiveOfSpades(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('5 of spades'));
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('5 of spades'));
  await tester.pump();
}

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  testWidgets('winning a match records it and shows coins, XP and achievements', (tester) async {
    await _phone(tester);
    await _stores();
    await tester.pumpWidget(_host(GameScreen(
      difficulty: AIDifficulty.hard,
      matchTarget: 3,
      controller: _oneFromMatchWin(),
    )));
    await tester.pumpAndSettle();

    await _playFiveOfSpades(tester);
    await tester.pumpAndSettle();

    final p = _profile.profile;
    expect(p.statsFor(AIDifficulty.hard).matchesWon, 1);
    expect(p.statsFor(AIDifficulty.hard).roundsWon, 1);
    expect(p.coins, greaterThan(0));
    expect(p.achievements, containsAll(['first_win', 'sharp_win']));
    expect(find.text('+${p.coins}'), findsOneWidget);
    expect(find.textContaining('Achievement: First Pat'), findsOneWidget);
  });

  testWidgets('the daily deal is the same for everyone on a date', (tester) async {
    final seed = dailySeed(_today);
    final a = GameController(difficulty: AIDifficulty.hard, matchTarget: 1, random: Random(seed));
    final b = GameController(difficulty: AIDifficulty.hard, matchTarget: 1, random: Random(seed));
    final tomorrow = GameController(random: Random(dailySeed(DateTime(2026, 10, 12))));
    expect(a.state.players[0].hand, b.state.players[0].hand);
    expect(a.state.topDiscard, b.state.topDiscard);
    expect(tomorrow.state.players[0].hand, isNot(a.state.players[0].hand));
    a.dispose();
    b.dispose();
    tomorrow.dispose();
  });

  testWidgets('daily challenge: play once, then it is done for the day', (tester) async {
    await _phone(tester);
    await _stores({'profile.v1': _profileJson({'daily': ['2026-10-10']})});
    await tester.pumpWidget(_host(const DailyScreen()));

    expect(find.text('1 day'), findsOneWidget); // yesterday's streak still alive
    expect(find.text("Play today's deal"), findsOneWidget);

    // Finish a daily as a one-round win
    await tester.pumpWidget(_host(GameScreen.daily(
      date: _today,
      controller: GameController(
        difficulty: AIDifficulty.hard,
        matchTarget: 1,
        initialState: makeState(
          matchTarget: 1,
          deck: [card(Rank.king, Suit.clubs, faceUp: false)],
          players: [
            Player(id: 'player1', name: 'Player', hand: [card(Rank.five, Suit.spades)], isAI: false),
            Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
          ],
        ),
      ),
    )));
    await tester.pumpAndSettle();
    await _playFiveOfSpades(tester);
    await tester.pumpAndSettle();

    expect(find.text('Daily challenge won!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Rematch'), findsNothing);
    expect(_profile.dailyDoneToday, isTrue);
    expect(_profile.dailyStreak, 2);
    expect(_profile.profile.statsFor(AIDifficulty.hard).matchesPlayed, 0);

    await tester.pumpWidget(_host(const DailyScreen()));
    await tester.pumpAndSettle();
    expect(find.text("Play today's deal"), findsNothing);
    expect(find.textContaining('Come back tomorrow'), findsOneWidget);
  });

  testWidgets('locker: buy and equip with enough coins', (tester) async {
    await _phone(tester);
    await _stores({'profile.v1': _profileJson({'coins': 500, 'xp': 0})});
    await tester.pumpWidget(_host(const LockerScreen()));

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Geometric, 150 coins')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(_profile.profile.coins, 350);
    expect(_profile.owns(cardBackId(CardBackStyle.geometric)), isTrue);
    expect(_settings.settings.cardBack, CardBackStyle.geometric);
    expect(find.bySemanticsLabel(RegExp(r'^Geometric, Equipped')), findsOneWidget);
  });

  testWidgets('locker: explains when short on coins or level-locked', (tester) async {
    await _phone(tester);
    await _stores({'profile.v1': _profileJson({'coins': 20})});
    await tester.pumpWidget(_host(const LockerScreen()));

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Geometric')));
    await tester.pump();
    expect(find.text('You need 130 more coins. Win matches to earn them!'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Royal')));
    await tester.pump();
    expect(find.text('Reach level 5 to unlock Royal'), findsOneWidget);
    expect(_profile.profile.coins, 20);
  });

  testWidgets('equipping an owned felt is free and instant', (tester) async {
    await _phone(tester);
    await _stores({'profile.v1': _profileJson({'owned': ['felt.royal']})});
    await tester.pumpWidget(_host(const LockerScreen()));
    await tester.tap(find.text('Felts'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Royal Blue, Tap to equip')));
    await tester.pump();
    expect(_settings.settings.felt, FeltStyle.royal);
  });

  testWidgets('stats screen shows level, streaks and per-difficulty records', (tester) async {
    await _phone(tester);
    await _stores({
      'profile.v1': _profileJson({
        'xp': 350,
        'streak': 2,
        'bestStreak': 4,
        'stats': {
          'medium': {'mp': 4, 'mw': 3, 'rp': 20, 'rw': 14},
        },
        'achievements': ['first_win'],
      }),
    });
    await tester.pumpWidget(_host(const StatsScreen()));

    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // best streak
    expect(find.textContaining('Achievements  1/'), findsOneWidget);
  });

  test('unequipUnowned resets cosmetics the player does not own', () async {
    await _stores({'cardBack': 'gradient', 'felt': 'midnight'});
    await unequipUnowned(_settings, _profile);
    expect(_settings.settings.cardBack, CardBackStyle.classic);
    expect(_settings.settings.felt, FeltStyle.teal);
  });
}
