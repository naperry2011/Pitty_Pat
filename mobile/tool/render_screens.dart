// Renders app screens to PNGs without a device, using the bundled fonts.
// For layout review and store screenshots (not part of the test suite):
//   OUT_DIR=<folder> flutter test tool/render_screens.dart
// Material icons aren't loaded, so icons render as squares.
// Test harness: uses the same test-only hooks as the widget tests.
// ignore_for_file: invalid_use_of_visible_for_testing_member
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
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/screens/home_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Duration? play, // let timers run this long first (AI turns, bubbles)
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  SharedPreferences.setMockInitialValues({'tutorialDone': true, ...prefs});
  final p = await SharedPreferences.getInstance();
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: SettingsScope(
        store: SettingsStore(p),
        child: ProfileScope(
          store: ProfileStore(p),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _theme,
            home: home,
          ),
        ),
      ),
    ),
  );
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
            .toImage(pixelRatio: 1);
    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$out/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(png!.buffer.asUint8List());
  });
  await tester.pumpWidget(const SizedBox());
  // ignore: avoid_print
  print('wrote $out/$name.png');
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

void main() {
  setUpAll(() async {
    await _loadFonts();
    defaultSoundPlayer = const MutedSoundPlayer();
  });

  testWidgets('render screens', (tester) async {
    const phone = Size(411, 914);
    const small = Size(360, 640);
    await _shot(tester, 'home', phone, const HomeScreen());
    for (final n in [1, 2, 3]) {
      await _shot(tester, 'table_${n + 1}p', phone, _table(n));
    }
    await _shot(tester, 'table_4p_small', small, _table(3));
    await _shot(tester, 'tutorial', phone, const GameScreen.tutorial());
    // Human draws, then Rosie takes her turn; the always-roll dice make her talk.
    await _shot(
      tester,
      'chatter',
      phone,
      _chatty(),
      play: const Duration(milliseconds: 2400),
    );
  });
}

class _AlwaysTalk implements Random {
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

// Rosie to move with a 5 against a 5, so she plays and announces her last card.
GameScreen _chatty() {
  final c = GameController(
    matchTarget: 5,
    opponentNames: const ['Rosie', 'Marcus'],
    random: Random(3),
  );
  final s = c.state;
  final five = s.topDiscard.copyWith(faceUp: true);
  final rosie = s.players[1].copyWith(
    hand: [
      PlayingCard(
        suit: five.suit == Suit.clubs ? Suit.hearts : Suit.clubs,
        rank: five.rank,
        faceUp: true,
      ),
      const PlayingCard(suit: Suit.spades, rank: Rank.two, faceUp: true),
    ],
  );
  return GameScreen(
    difficulty: AIDifficulty.easy,
    matchTarget: 5,
    opponents: 2,
    chatRandom: _AlwaysTalk(),
    controller: GameController(
      opponentNames: const ['Rosie', 'Marcus'],
      initialState: s.copyWith(
        currentPlayerIndex: 1,
        players: [s.players[0], rosie, s.players[2]],
      ),
    ),
  );
}
