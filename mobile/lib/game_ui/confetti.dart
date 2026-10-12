import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cards/suit_shapes.dart';
import '../cosmetics/catalog.dart';
import '../game/models.dart';
import '../theme/tokens.dart';

// Port of the Confetti component in GameBoard.tsx, with unlockable styles.
// Piece attributes derive deterministically from the index, so a burst looks
// the same every time.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.count = 50,
    this.style = CelebrationStyle.confetti,
    this.duration = const Duration(seconds: 3),
    this.onDone,
  });

  final int count;
  final CelebrationStyle style;
  final Duration duration;
  final VoidCallback? onDone;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone?.call();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_c, widget.count, widget.style),
        ),
      );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.count, this.style) : super(repaint: anim);

  final Animation<double> anim;
  final int count;
  final CelebrationStyle style;

  static const _confettiColors = [
    AppColors.coral,
    AppColors.gold,
    AppColors.felt,
    AppColors.cream,
    AppColors.softPurple,
  ];
  static const _goldColors = [AppColors.gold, Color(0xFFFFD873), AppColors.sunny, AppColors.cream];
  static const _suitColors = [AppColors.coralDeep, AppColors.ink, AppColors.coral, Color(0xFF475569)];

  List<Color> get _colors => switch (style) {
        CelebrationStyle.confetti => _confettiColors,
        CelebrationStyle.goldRush => _goldColors,
        CelebrationStyle.suitShower => _suitColors,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = anim.value; // 0..1 of the whole burst
    final paint = Paint();
    final colors = _colors;

    for (var i = 0; i < count; i++) {
      final left = ((i * 137) % 100) / 100;
      final delay = ((i * 31) % 20) / 10 / 3; // up to ~2/3 of the burst
      final fall = (1 - delay).clamp(0.3, 1.0);
      final t = ((elapsed - delay) / fall).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;

      final pieceSize = 8.0 + ((i * 97) % 9);
      final drift = i % 4 == 0 ? math.sin(t * math.pi * 2) * 30 : 0.0;
      final x = left * size.width + drift;
      final y = -20 + t * (size.height + 40);

      paint.color = colors[i % colors.length].withValues(alpha: 1 - t * t);
      canvas.save();
      canvas.translate(x, y);

      switch (style) {
        case CelebrationStyle.suitShower:
          // Suits tumble gently and stay readable
          canvas.rotate(math.sin(t * math.pi * 3 + i) * 0.6);
          canvas.drawPath(suitPath(Suit.values[i % 4], pieceSize * 1.8), paint);
        case CelebrationStyle.goldRush:
          // Coins: ellipses that flip as they fall
          final flip = math.cos(t * math.pi * 6 + i).abs().clamp(0.15, 1.0);
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: pieceSize * 1.4 * flip, height: pieceSize * 1.4),
            paint,
          );
        case CelebrationStyle.confetti:
          canvas.rotate(t * math.pi * 4);
          switch (i % 3) {
            case 0:
              canvas.drawCircle(Offset.zero, pieceSize / 2, paint);
            case 1:
              canvas.drawRRect(
                RRect.fromRectAndRadius(
                  Rect.fromCenter(center: Offset.zero, width: pieceSize, height: pieceSize),
                  const Radius.circular(2),
                ),
                paint,
              );
            default:
              canvas.drawRect(
                Rect.fromCenter(center: Offset.zero, width: pieceSize / 2, height: pieceSize * 2),
                paint,
              );
          }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.count != count || old.style != style;
}
