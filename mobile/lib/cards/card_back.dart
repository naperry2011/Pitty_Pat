import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'card_face.dart' show cardDesignSize;
import 'suit_shapes.dart';

// Port of components/game/CardBackDesign.tsx (240x360 design canvas).
enum CardBackStyle { classic, geometric, gradient, minimal, midnight, royal }

class CardBack extends StatelessWidget {
  const CardBack({super.key, required this.style});

  final CardBackStyle style;

  @override
  Widget build(BuildContext context) {
    final family = displayFontFamily(context);
    Widget? crest;
    switch (style) {
      case CardBackStyle.classic:
        crest = _crestText('PP', 38, AppColors.coralDeep, 195, family);
      case CardBackStyle.geometric:
        crest = _crestText('PP', 30, AppColors.feltDeep, 191, family);
      case CardBackStyle.royal:
        crest = _crestText('PP', 30, AppColors.gold, 222, family);
      case CardBackStyle.gradient:
      case CardBackStyle.minimal:
      case CardBackStyle.midnight:
        crest = null;
    }

    return ExcludeSemantics(
      child: FittedBox(
        child: SizedBox.fromSize(
          size: cardDesignSize,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _BackPainter(style))),
              ?crest,
            ],
          ),
        ),
      ),
    );
  }

  Widget _crestText(String text, double fontSize, Color color, double baseline, String? family) =>
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: Baseline(
          baseline: baseline,
          baselineType: TextBaseline.alphabetic,
          child: SizedBox(
            width: cardDesignSize.width,
            child: Text(
              text,
              textAlign: TextAlign.center,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontFamily: family,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1,
              ),
            ),
          ),
        ),
      );
}

class _BackPainter extends CustomPainter {
  _BackPainter(this.style);

  final CardBackStyle style;

  static final _outer = RRect.fromRectAndRadius(
    Offset.zero & cardDesignSize,
    const Radius.circular(16),
  );

  Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRRect(_outer);
    switch (style) {
      case CardBackStyle.classic:
        _classic(canvas);
      case CardBackStyle.geometric:
        _geometric(canvas);
      case CardBackStyle.gradient:
        _gradient(canvas);
      case CardBackStyle.minimal:
        _minimal(canvas);
      case CardBackStyle.midnight:
        _midnight(canvas);
      case CardBackStyle.royal:
        _royal(canvas);
    }
  }

  void _classic(Canvas canvas) {
    canvas.drawRRect(
      _outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.coral, AppColors.coralDeep],
        ).createShader(Offset.zero & cardDesignSize),
    );

    final inner = RRect.fromLTRBR(14, 14, 226, 346, const Radius.circular(10));
    canvas.save();
    canvas.clipRRect(inner);
    final lattice = _stroke(AppColors.cream.withValues(alpha: 0.35), 2);
    for (double y = 0; y < 360; y += 28) {
      for (double x = 0; x < 240; x += 28) {
        canvas.drawPath(
          Path()
            ..moveTo(x, y + 14)
            ..lineTo(x + 14, y)
            ..lineTo(x + 28, y + 14)
            ..lineTo(x + 14, y + 28)
            ..close(),
          lattice,
        );
      }
    }
    canvas.restore();

    canvas.drawRRect(inner, _stroke(AppColors.gold, 3));
    canvas.drawRRect(
      RRect.fromLTRBR(6, 6, 234, 354, const Radius.circular(13)),
      _stroke(AppColors.cream.withValues(alpha: 0.7), 2),
    );

    const center = Offset(120, 180);
    canvas.drawCircle(center, 42, Paint()..color = AppColors.gold);
    canvas.drawCircle(center, 42, _stroke(AppColors.cream, 3));
    canvas.drawCircle(center, 33, _stroke(AppColors.coralDeep, 2));
  }

  void _geometric(Canvas canvas) {
    canvas.drawRRect(_outer, Paint()..color = AppColors.feltDeep);

    final inner = RRect.fromLTRBR(12, 12, 228, 348, const Radius.circular(10));
    canvas.save();
    canvas.clipRRect(inner);
    final felt = Paint()..color = AppColors.felt;
    final deep = Paint()..color = AppColors.feltDeep;
    final creamStrong = Paint()..color = AppColors.cream.withValues(alpha: 0.85);
    final creamSoft = Paint()..color = AppColors.cream.withValues(alpha: 0.25);
    // SVG pattern tiles start at the canvas origin (userSpaceOnUse)
    for (double y = 0; y < 360; y += 44) {
      for (double x = 0; x < 240; x += 50) {
        canvas.drawRect(Rect.fromLTWH(x, y, 50, 44), felt);
        canvas.drawPath(_tri(x, y + 44, x + 25, y, x + 50, y + 44), deep);
        canvas.drawPath(_tri(x + 25, y + 44, x + 37.5, y + 22, x + 50, y + 44), creamStrong);
        canvas.drawPath(_tri(x, y + 44, x + 12.5, y + 22, x + 25, y + 44), creamSoft);
      }
    }
    canvas.restore();

    canvas.drawRRect(inner, _stroke(AppColors.cream, 3));
    canvas.drawRRect(
      RRect.fromLTRBR(5, 5, 235, 355, const Radius.circular(13)),
      _stroke(AppColors.cream.withValues(alpha: 0.4), 2),
    );

    canvas.save();
    canvas.translate(120, 180);
    canvas.rotate(math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 52, height: 52),
        const Radius.circular(6),
      ),
      Paint()..color = AppColors.cream,
    );
    canvas.restore();
  }

  Path _tri(double x1, double y1, double x2, double y2, double x3, double y3) => Path()
    ..moveTo(x1, y1)
    ..lineTo(x2, y2)
    ..lineTo(x3, y3)
    ..close();

  // Deterministic star positions (x, y, r)
  static const _stars = [
    (38.0, 52.0, 3.0), (115.0, 36.0, 2.0), (192.0, 62.0, 3.5), (67.0, 113.0, 2.0),
    (173.0, 134.0, 2.5), (34.0, 195.0, 2.5), (206.0, 206.0, 2.0), (86.0, 247.0, 3.0),
    (154.0, 278.0, 2.0), (53.0, 309.0, 2.0), (192.0, 319.0, 3.0),
  ];

  void _gradient(Canvas canvas) {
    canvas.drawRRect(
      _outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.coral, AppColors.softPurple],
        ).createShader(Offset.zero & cardDesignSize),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(10, 10, 230, 350, const Radius.circular(11)),
      _stroke(AppColors.cream.withValues(alpha: 0.6), 2),
    );

    final star = Paint()..color = AppColors.cream.withValues(alpha: 0.65);
    for (final (x, y, r) in _stars) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r * 2)
          ..quadraticBezierTo(x + r * 0.5, y - r * 0.5, x + r * 2, y)
          ..quadraticBezierTo(x + r * 0.5, y + r * 0.5, x, y + r * 2)
          ..quadraticBezierTo(x - r * 0.5, y + r * 0.5, x - r * 2, y)
          ..quadraticBezierTo(x - r * 0.5, y - r * 0.5, x, y - r * 2)
          ..close(),
        star,
      );
    }

    // Crescent moon
    canvas.drawCircle(const Offset(120, 180), 26, Paint()..color = AppColors.cream.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(129, 173), 22, Paint()..color = AppColors.coral.withValues(alpha: 0.55));
    canvas.drawCircle(const Offset(129, 173), 22, Paint()..color = AppColors.softPurple.withValues(alpha: 0.5));
  }

  void _minimal(Canvas canvas) {
    canvas.drawRRect(_outer, Paint()..color = AppColors.cream);
    canvas.drawRRect(
      RRect.fromLTRBR(14, 14, 226, 346, const Radius.circular(10)),
      _stroke(AppColors.coral, 3),
    );
    canvas.drawPath(
      Path()
        ..moveTo(120, 201)
        ..cubicTo(98, 183, 91, 169, 91, 157)
        ..cubicTo(91, 144, 101, 136, 111, 136)
        ..cubicTo(116, 136, 120, 139, 120, 143)
        ..cubicTo(120, 139, 124, 136, 129, 136)
        ..cubicTo(139, 136, 149, 144, 149, 157)
        ..cubicTo(149, 169, 142, 183, 120, 201)
        ..close(),
      Paint()..color = AppColors.coral,
    );
    canvas.drawCircle(const Offset(120, 225), 3, Paint()..color = AppColors.coralDeep);
  }

  // Unlockable: deep navy, gold double frame, four-suit compass.
  void _midnight(Canvas canvas) {
    canvas.drawRRect(
      _outer,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 0.9,
          colors: [Color(0xFF2D3A5C), Color(0xFF111729)],
        ).createShader(Offset.zero & cardDesignSize),
    );
    canvas.drawRRect(RRect.fromLTRBR(10, 10, 230, 350, const Radius.circular(11)), _stroke(AppColors.gold, 2));
    canvas.drawRRect(
      RRect.fromLTRBR(18, 18, 222, 342, const Radius.circular(8)),
      _stroke(AppColors.gold.withValues(alpha: 0.45), 1),
    );

    final dot = Paint()..color = AppColors.cream.withValues(alpha: 0.18);
    for (double y = 34; y < 330; y += 22) {
      for (double x = 34; x < 210; x += 22) {
        canvas.drawCircle(Offset(x + ((y ~/ 22).isEven ? 0 : 11), y), 1.4, dot);
      }
    }

    const c = Offset(120, 180);
    canvas.drawCircle(c, 46, Paint()..color = const Color(0xFF111729));
    canvas.drawCircle(c, 46, _stroke(AppColors.gold, 2));
    final gold = AppColors.gold;
    for (final (suit, offset) in [
      (Suit.spades, const Offset(0, -24)),
      (Suit.hearts, const Offset(24, 0)),
      (Suit.clubs, const Offset(0, 24)),
      (Suit.diamonds, const Offset(-24, 0)),
    ]) {
      drawSuit(canvas, suit, c + offset, 20, gold);
    }
  }

  // Unlockable: plum velvet with a gold crown crest.
  void _royal(Canvas canvas) {
    canvas.drawRRect(
      _outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7B2D8E), Color(0xFF4A1259)],
        ).createShader(Offset.zero & cardDesignSize),
    );

    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.06);
    for (double x = -360; x < 240; x += 24) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 360)
          ..lineTo(x + 12, 360)
          ..lineTo(x + 372, 0)
          ..lineTo(x + 360, 0)
          ..close(),
        stripe,
      );
    }

    canvas.drawRRect(RRect.fromLTRBR(12, 12, 228, 348, const Radius.circular(10)), _stroke(AppColors.gold, 3));
    canvas.drawPath(
      Path()
        ..moveTo(78, 196)
        ..lineTo(78, 146)
        ..lineTo(99, 166)
        ..lineTo(120, 132)
        ..lineTo(141, 166)
        ..lineTo(162, 146)
        ..lineTo(162, 196)
        ..close(),
      Paint()..color = AppColors.gold,
    );
    for (final x in [78.0, 120.0, 162.0]) {
      canvas.drawCircle(Offset(x, x == 120 ? 128 : 142), 6, Paint()..color = AppColors.gold);
    }
  }

  @override
  bool shouldRepaint(_BackPainter old) => old.style != style;
}
