// Renders app screens to PNGs without a device, using the bundled fonts.
// Not part of the test suite. Two modes:
//   OUT_DIR=<folder> flutter test tool/render_screens.dart           layout review
//   STORE=1 OUT_DIR=<folder> flutter test tool/render_screens.dart   Play Store set (1080x1920)
// Store PNGs come out 32-bit; flatten them to 24-bit before upload (see docs/release).
// Test harness: uses the same test-only hooks as the widget tests.
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/profile/daily.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/daily_screen.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/screens/home_screen.dart';
import 'package:pitty_pat/screens/locker_screen.dart';
import 'package:pitty_pat/screens/pass_play_setup_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _today = DateTime(2026, 10, 11);

Future<void> _loadFonts() async {
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await (FontLoader(
      'Fredoka',
    )..addFont(rootBundle.load('assets/google_fonts/Fredoka-$w.ttf'))).load();
  }
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/google_fonts/Inter-$w.ttf'))).load();
  }
  // Material icons ship with the Flutter SDK; without them icons render as squares.
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  );
  if (root != null && icons.existsSync()) {
    final bytes = icons.readAsBytesSync();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}

final _theme = ThemeData(
  fontFamily: 'Inter',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Fredoka'),
    displaySmall: TextStyle(fontFamily: 'Fredoka'),
    headlineSmall: TextStyle(fontFamily: 'Fredoka'),
    titleLarge: TextStyle(fontFamily: 'Fredoka'),
  ),
);

Future<void> _shot(
  WidgetTester tester,
  String name,
  Size size,
  Widget home, {
  Map<String, Object> prefs = const {},
  double pixelRatio = 2,
  Duration? play, // let timers run this long first (AI turns, bubbles)
  void Function(GameController controller)?
  act, // moves to make before the capture
  String? tapText, // a button to press before the capture
}) async {
  tester.view.physicalSize = size * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  SharedPreferences.setMockInitialValues({'tutorialDone': true, ...prefs});
  final p = await SharedPreferences.getInstance();
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: SettingsScope(
        store: SettingsStore(p),
        child: ProfileScope(
          store: ProfileStore(p, now: () => _today),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _theme,
            home: home,
          ),
        ),
      ),
    ),
  );
  if (act != null) {
    await tester.pumpAndSettle();
    act(tester.widget<GameScreen>(find.byType(GameScreen)).controller!);
  }
  if (tapText != null) {
    await tester.pumpAndSettle();
    await tester.tap(find.text(tapText));
  }
  if (play != null) {
    for (
      var t = Duration.zero;
      t < play;
      t += const Duration(milliseconds: 100)
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  } else {
    await tester.pumpAndSettle();
  }
  final out = Platform.environment['OUT_DIR'] ?? 'build/screens';
  await tester.runAsync(() async {
    final img =
        await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
            .toImage(pixelRatio: pixelRatio);
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    File('$out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
  await tester.pumpWidget(const SizedBox());
  // ignore: avoid_print
  print('wrote $out/$name.png');
}

class _AlwaysTalk implements Random {
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

GameScreen _table(int opponents) => GameScreen(
  difficulty: AIDifficulty.easy,
  matchTarget: 5,
  opponents: opponents,
  controller: GameController(
    matchTarget: 5,
    opponentNames: const ['Rosie', 'Marcus', 'Dee'].sublist(0, opponents),
    random: Random(3),
  ),
);

// Cards by short code: '7H' = 7 of hearts, '10S' = 10 of spades.
PlayingCard _c(String code, {bool up = true}) {
  final rank = Rank.values.firstWhere(
    (r) => r.label == code.substring(0, code.length - 1),
  );
  final suit = {
    'H': Suit.hearts,
    'D': Suit.diamonds,
    'C': Suit.clubs,
    'S': Suit.spades,
  }[code[code.length - 1]]!;
  return PlayingCard(rank: rank, suit: suit, faceUp: up);
}

// A consistent position: every card exists exactly once across hands, pile and deck.
GameState _rig({
  required String top,
  required List<List<String>> hands, // [human, opponents...]
  required List<String> names,
  List<int>? wins,
  int current = 0,
  int matchTarget = 5,
}) {
  final used = [top, for (final h in hands) ...h];
  assert(used.toSet().length == used.length, 'duplicate card in rig: $used');
  final usedIds = {for (final code in used) _c(code).id};
  return GameState(
    deck: [
      for (final c in createDeck())
        if (!usedIds.contains(c.id)) c,
    ],
    discardPile: [_c(top)],
    players: [
      for (var i = 0; i < hands.length; i++)
        Player(
          id: i == 0 ? 'player1' : 'ai$i',
          name: i == 0 ? 'Player' : names[i - 1],
          hand: [for (final code in hands[i]) _c(code)],
          isAI: i > 0,
          wins: wins?[i] ?? 0,
        ),
    ],
    currentPlayerIndex: current,
    phase: GamePhase.playing,
    winner: null,
    turnAction: TurnAction.draw,
    message: current == 0 ? 'Your turn' : "${names[current - 1]}'s turn",
    selectedCardId: null,
    matchTarget: matchTarget,
  );
}

// Rosie to move with a 7 on a 7 plus one other card: she plays and calls her last card.
GameScreen _chatty() => GameScreen(
  difficulty: AIDifficulty.medium,
  matchTarget: 5,
  opponents: 3,
  chatRandom: _AlwaysTalk(),
  controller: GameController(
    opponentNames: const ['Rosie', 'Marcus', 'Dee'],
    initialState: _rig(
      top: '7H',
      hands: [
        ['2C', '9D', 'KS', '4H', 'JC'],
        ['7C', '3D'],
        ['5S', '8H', 'QD', '10C', 'AS'],
        ['6D', 'JH', '3C'],
      ],
      names: const ['Rosie', 'Marcus', 'Dee'],
      wins: const [2, 1, 1, 2],
      current: 1,
    ),
  ),
);

// Human to move holding a 9 for the 9 on the pile.
GameScreen _readyToPlay() => GameScreen(
  difficulty: AIDifficulty.medium,
  matchTarget: 5,
  controller: GameController(
    opponentNames: const ['Auntie Bev'],
    initialState: _rig(
      top: '9S',
      hands: [
        ['3C', 'QH', '9D', '6S', 'AD'],
        ['2H', 'KC', '5D', '8S'],
      ],
      names: const ['Auntie Bev'],
      wins: const [2, 1],
    ),
  ),
);

// One card from winning a first-to-3 match against Sharp.
GameScreen _aboutToWin() => GameScreen(
  difficulty: AIDifficulty.hard,
  matchTarget: 3,
  controller: GameController(
    matchTarget: 3,
    opponentNames: const ['Dee'],
    initialState: _rig(
      top: '4D',
      hands: [
        ['4C'],
        ['JS', '7D', '2H'],
      ],
      names: const ['Dee'],
      wins: const [2, 1],
      matchTarget: 3,
    ),
  ),
);

String _profile(Map<String, Object> fields) => jsonEncode({'v': 1, ...fields});

List<String> _streakDays(int days) => [
  for (var i = 1; i <= days; i++)
    dateKey(DateTime(_today.year, _today.month, _today.day - i)),
];

void main() {
  setUpAll(() async {
    await _loadFonts();
    defaultSoundPlayer = const MutedSoundPlayer();
  });

  final store = Platform.environment['STORE'] == '1';

  testWidgets('render screens', skip: store, (tester) async {
    const phone = Size(411, 914);
    const small = Size(360, 640);
    await _shot(tester, 'home', phone, const HomeScreen());
    for (final n in [1, 2, 3]) {
      await _shot(tester, 'table_${n + 1}p', phone, _table(n));
    }
    await _shot(tester, 'table_4p_small', small, _table(3));
    await _shot(tester, 'tutorial', phone, const GameScreen.tutorial());
    await _shot(
      tester,
      'chatter',
      phone,
      _chatty(),
      play: const Duration(milliseconds: 2400),
    );
    const pass = GameScreen.passAndPlay(playerNames: ['Mia', 'Jay', 'Sam', 'Dre'], matchTarget: 5);
    await _shot(tester, 'pass_setup', phone, const PassPlaySetupScreen(), prefs: {'passPlayers': 4});
    await _shot(tester, 'pass_cover', phone, pass);
    await _shot(tester, 'pass_board', phone, pass, tapText: "I'm Mia, show my cards");
  });

  testWidgets('render store screenshots', skip: !store, (tester) async {
    // 405x720 logical at 8/3 = exactly 1080x1920 (9:16), Google's recommended game size.
    const size = Size(405, 720);
    const ratio = 8 / 3;
    final progress = {
      'profile.v1': _profile({
        'coins': 640,
        'xp': 720,
        'streak': 3,
        'bestStreak': 5,
        'owned': [
          'back.classic',
          'back.minimal',
          'back.geometric',
          'back.midnight',
          'felt.teal',
          'felt.royal',
        ],
        'daily': _streakDays(4),
        'dailyWon': _streakDays(3),
        'achievements': ['first_win', 'sharp_win', 'daily_first'],
      }),
      'cardBack': 'midnight',
      'felt': 'royal',
    };

    await _shot(
      tester,
      '1_home',
      size,
      const HomeScreen(),
      prefs: progress,
      pixelRatio: ratio,
    );
    await _shot(
      tester,
      '2_table',
      size,
      _chatty(),
      prefs: progress,
      pixelRatio: ratio,
      play: const Duration(milliseconds: 2400),
    );
    await _shot(
      tester,
      '3_play',
      size,
      _readyToPlay(),
      prefs: progress,
      pixelRatio: ratio,
      // Select the matching card so "TAP TO PLAY" shows.
      act: (c) => c.tapCard('9-diamonds'),
    );
    await _shot(
      tester,
      '4_win',
      size,
      _aboutToWin(),
      prefs: progress,
      pixelRatio: ratio,
      act: (c) => c
        ..tapCard('4-clubs')
        ..tapCard('4-clubs'),
      play: const Duration(milliseconds: 1200),
    );
    await _shot(
      tester,
      '5_locker',
      size,
      const LockerScreen(),
      prefs: progress,
      pixelRatio: ratio,
    );
    await _shot(
      tester,
      '6_daily',
      size,
      const DailyScreen(),
      prefs: progress,
      pixelRatio: ratio,
    );
  });
}
