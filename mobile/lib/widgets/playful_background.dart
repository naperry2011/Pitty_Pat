import 'package:flutter/material.dart';

// Port of .playful-bg: sky gradient with soft color glows.
class PlayfulBackground extends StatelessWidget {
  const PlayfulBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF87CEEB), Color(0xFFB8D4E3), Color(0xFFE6E6FA)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _Glow(Alignment(-0.6, -0.6), Color(0x26FFE66D), 0.4),
            const _Glow(Alignment(0.6, 0.6), Color(0x1AFF6B6B), 0.4),
            const _Glow(Alignment.center, Color(0x1A4ECDC4), 0.6),
            child,
          ],
        ),
      );
}

class _Glow extends StatelessWidget {
  const _Glow(this.center, this.color, this.radius);

  final Alignment center;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: center,
              radius: radius,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      );
}
