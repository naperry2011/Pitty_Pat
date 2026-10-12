import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'suit_shapes.dart';

// Port of components/game/CardFace.tsx. Drawn on a 240x360 design canvas
// (exact 2:3 ratio) and scaled to fit, so coordinates match the web SVG.
const cardDesignSize = Size(240, 360);

const _l = 66.0;
const _c = 120.0;
const _r = 174.0;

const Map<Rank, List<Offset>> _pipLayouts = {
  Rank.ace: [Offset(_c, 180)],
  Rank.two: [Offset(_c, 72), Offset(_c, 288)],
  Rank.three: [Offset(_c, 72), Offset(_c, 180), Offset(_c, 288)],
  Rank.four: [Offset(_l, 72), Offset(_r, 72), Offset(_l, 288), Offset(_r, 288)],
  Rank.five: [Offset(_l, 72), Offset(_r, 72), Offset(_c, 180), Offset(_l, 288), Offset(_r, 288)],
  Rank.six: [
    Offset(_l, 72), Offset(_r, 72), Offset(_l, 180), Offset(_r, 180), //
    Offset(_l, 288), Offset(_r, 288),
  ],
  Rank.seven: [
    Offset(_l, 72), Offset(_r, 72), Offset(_c, 126), Offset(_l, 180), //
    Offset(_r, 180), Offset(_l, 288), Offset(_r, 288),
  ],
  Rank.eight: [
    Offset(_l, 72), Offset(_r, 72), Offset(_c, 126), Offset(_l, 180), //
    Offset(_r, 180), Offset(_c, 234), Offset(_l, 288), Offset(_r, 288),
  ],
  Rank.nine: [
    Offset(_l, 72), Offset(_r, 72), Offset(_l, 126), Offset(_r, 126), Offset(_c, 180), //
    Offset(_l, 234), Offset(_r, 234), Offset(_l, 288), Offset(_r, 288),
  ],
  Rank.ten: [
    Offset(_l, 72), Offset(_r, 72), Offset(_c, 99), Offset(_l, 126), Offset(_r, 126), //
    Offset(_l, 234), Offset(_r, 234), Offset(_c, 261), Offset(_l, 288), Offset(_r, 288),
  ],
};

bool _isFaceCard(Rank r) => r == Rank.jack || r == Rank.queen || r == Rank.king;

Color suitColor(Suit s) =>
    (s == Suit.hearts || s == Suit.diamonds) ? AppColors.suitRed : AppColors.suitBlack;

class CardFace extends StatelessWidget {
  const CardFace({super.key, required this.rank, required this.suit});

  final Rank rank;
  final Suit suit;

  @override
  Widget build(BuildContext context) {
    final color = suitColor(suit);
    final family = displayFontFamily(context);
    final indexStyle = TextStyle(
      fontFamily: family,
      fontSize: 46,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1,
    );

    return Semantics(
      container: true,
      label: '${rank.label} of ${suit.name}',
      excludeSemantics: true,
      child: FittedBox(
        child: SizedBox.fromSize(
          size: cardDesignSize,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _FacePainter(rank, suit, color))),
              _CornerIndex(label: rank.label, style: indexStyle),
              Positioned.fill(
                child: Transform.rotate(
                  angle: 3.141592653589793,
                  child: Stack(children: [_CornerIndex(label: rank.label, style: indexStyle)]),
                ),
              ),
              if (_isFaceCard(rank)) ...[
                _BaselineText(
                  x: 120,
                  baseline: 268,
                  text: rank.label,
                  style: TextStyle(
                    fontFamily: family,
                    fontSize: 130,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = color,
                  ),
                ),
                _BaselineText(
                  x: 120,
                  baseline: 268,
                  text: rank.label,
                  style: TextStyle(
                    fontFamily: family,
                    fontSize: 130,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerIndex extends StatelessWidget {
  const _CornerIndex({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) =>
      _BaselineText(x: 26, baseline: 44, text: label, style: style);
}

// Places text like SVG <text text-anchor="middle">: centered on x, baseline at y.
class _BaselineText extends StatelessWidget {
  const _BaselineText({
    required this.x,
    required this.baseline,
    required this.text,
    required this.style,
  });

  final double x;
  final double baseline;
  final String text;
  final TextStyle style;

  static const _boxWidth = 220.0;

  @override
  Widget build(BuildContext context) => Positioned(
        left: x - _boxWidth / 2,
        top: 0,
        width: _boxWidth,
        child: Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: SizedBox(
            width: _boxWidth,
            child: Text(
              text,
              textAlign: TextAlign.center,
              textScaler: TextScaler.noScaling,
              maxLines: 1,
              softWrap: false,
              style: style,
            ),
          ),
        ),
      );
}

class _FacePainter extends CustomPainter {
  _FacePainter(this.rank, this.suit, this.color);

  final Rank rank;
  final Suit suit;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16));
    canvas.drawRRect(outer, Paint()..color = Colors.white);
    canvas.drawRRect(
      outer.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x1F2D3142),
    );
    canvas.drawRRect(
      outer.deflate(3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xE6FFFFFF),
    );

    // Corner suit under the index, and its 180-degree copy
    drawSuit(canvas, suit, const Offset(26, 66), 24, color);
    drawSuit(canvas, suit, const Offset(214, 294), 24, color, flipped: true);

    if (_isFaceCard(rank)) {
      _paintMotif(canvas);
      return;
    }

    final pipSize = rank == Rank.ace ? 76.0 : 36.0;
    for (final pip in _pipLayouts[rank]!) {
      // Pips below the midline render upside-down, like a real deck
      drawSuit(canvas, suit, pip, pipSize, color, flipped: pip.dy > 180);
    }
  }

  void _paintMotif(Canvas canvas) {
    final gold = Paint()..color = AppColors.gold;
    switch (rank) {
      case Rank.jack: // Feather
        canvas.drawPath(
          Path()
            ..moveTo(90, 135)
            ..quadraticBezierTo(120, 75, 155, 100)
            ..quadraticBezierTo(145, 140, 100, 143)
            ..close(),
          gold,
        );
        canvas.drawPath(
          Path()
            ..moveTo(90, 135)
            ..quadraticBezierTo(120, 100, 150, 103),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = AppColors.cream,
        );
        canvas.drawLine(
          const Offset(90, 135),
          const Offset(77, 150),
          Paint()
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..color = AppColors.gold,
        );
      case Rank.queen: // Tiara
        canvas.drawPath(
          Path()
            ..moveTo(70, 140)
            ..lineTo(80, 105)
            ..lineTo(100, 127)
            ..lineTo(120, 93)
            ..lineTo(140, 127)
            ..lineTo(160, 105)
            ..lineTo(170, 140)
            ..close(),
          gold,
        );
        canvas.drawCircle(const Offset(80, 101), 6, gold);
        canvas.drawCircle(const Offset(120, 89), 6, gold);
        canvas.drawCircle(const Offset(160, 101), 6, gold);
      case Rank.king: // Crown
        canvas.drawPath(
          Path()
            ..moveTo(67, 143)
            ..lineTo(67, 100)
            ..lineTo(91, 120)
            ..lineTo(120, 87)
            ..lineTo(149, 120)
            ..lineTo(173, 100)
            ..lineTo(173, 143)
            ..close(),
          gold,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(67, 143, 106, 10), const Radius.circular(3)),
          gold,
        );
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.rank != rank || old.suit != suit;
}
