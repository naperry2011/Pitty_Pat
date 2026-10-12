// Renders launcher icon, splash and Play Store art from the real card widgets.
// Not part of the test suite (lives outside test/). Regenerate with:
//   flutter test tool/render_art.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/cards/card_back.dart';
import 'package:pitty_pat/cards/playing_card_view.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/theme/tokens.dart';

final _theme = ThemeData(
  textTheme: const TextTheme(displayLarge: TextStyle(fontFamily: 'Fredoka')),
);

// The home-screen fan: A of hearts, a Classic back, A of spades.
class _CardFan extends StatelessWidget {
  const _CardFan({required this.cardWidth});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final spread = cardWidth * 0.5;
    final cards = [
      (const PlayingCard(suit: Suit.hearts, rank: Rank.ace, faceUp: true), -0.30, -spread),
      (const PlayingCard(suit: Suit.spades, rank: Rank.ace), 0.0, 0.0),
      (const PlayingCard(suit: Suit.spades, rank: Rank.ace, faceUp: true), 0.30, spread),
    ];
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final (card, angle, dx) in cards)
          Transform.translate(
            offset: Offset(dx, dx.abs() * 0.15),
            child: Transform.rotate(
              angle: angle,
              child: PlayingCardView(card: card, width: cardWidth, backStyle: CardBackStyle.classic),
            ),
          ),
      ],
    );
  }
}

class _Felt extends StatelessWidget {
  const _Felt({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 0.9,
            colors: [Color(0xFF36B3A2), AppColors.feltDeep],
          ),
        ),
        child: child ?? const SizedBox.expand(),
      );
}

Future<void> _render(WidgetTester tester, Size size, String path, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final key = GlobalKey();
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _theme,
    // Transparent Material: gives Text a real style (no debug underline) without painting.
    home: Material(
      type: MaterialType.transparency,
      child: Center(
        child: RepaintBoundary(key: key, child: SizedBox.fromSize(size: size, child: child)),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
  // ignore: avoid_print
  print('wrote $path (${size.width.toInt()}x${size.height.toInt()})');
}

void main() {
  setUpAll(() async {
    final fredoka = FontLoader('Fredoka')..addFont(rootBundle.load('assets/google_fonts/Fredoka-Bold.ttf'));
    await fredoka.load();
  });

  testWidgets('render art', (tester) async {
    const icon = Size(1024, 1024);

    // Full icon (iOS, legacy Android, store): felt + fan filling most of the square.
    await _render(tester, icon, 'assets/icon/icon.png', const _Felt(child: Center(child: _CardFan(cardWidth: 360))));

    // Adaptive layers. Foreground art stays inside the ~66% safe zone (inset set to 0 in config).
    await _render(tester, icon, 'assets/icon/icon_background.png', const _Felt());
    await _render(tester, icon, 'assets/icon/icon_foreground.png', const Center(child: _CardFan(cardWidth: 250)));

    // Android 12+ splash: no background, fits a 768px circle in a 1152 canvas.
    await _render(tester, const Size(1152, 1152), 'assets/splash/splash_android12.png',
        const Center(child: _CardFan(cardWidth: 270)));
    // Pre-Android 12 / iOS splash center image.
    await _render(tester, const Size(600, 600), 'assets/splash/splash.png',
        const Center(child: _CardFan(cardWidth: 190)));

    // Play Store icon (512x512, full square).
    await _render(tester, const Size(512, 512), '../docs/release/store/play_icon_512.png',
        const _Felt(child: Center(child: _CardFan(cardWidth: 180))));

    // Play Store feature graphic (1024x500).
    await _render(
      tester,
      const Size(1024, 500),
      '../docs/release/store/feature_graphic_1024x500.png',
      _Felt(
        child: Row(
          children: [
            SizedBox(
              width: 430,
              child: Center(
                child: Transform.rotate(angle: -math.pi / 40, child: const _CardFan(cardWidth: 150)),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pitty Pat',
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 104, color: AppColors.cream, height: 1),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Match the rank. Empty your hand. Win.',
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 30, color: AppColors.gold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}
