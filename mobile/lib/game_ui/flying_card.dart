import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cards/card_back.dart';
import '../cards/playing_card_view.dart';
import '../game/models.dart';

// A card travelling from a hand or the deck to the discard pile along an arc,
// optionally flipping face-up mid-flight (draws and AI plays).
class CardFlight {
  CardFlight({
    required this.card,
    required this.from,
    required this.to,
    required this.flip,
    required this.backStyle,
  });

  final PlayingCard card;
  final Rect from;
  final Rect to;
  final bool flip;
  final CardBackStyle backStyle;
}

class FlyingCard extends StatefulWidget {
  const FlyingCard({super.key, required this.flight, required this.onDone});

  final CardFlight flight;
  final VoidCallback onDone;

  static const duration = Duration(milliseconds: 360);

  @override
  State<FlyingCard> createState() => _FlyingCardState();
}

class _FlyingCardState extends State<FlyingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: FlyingCard.duration)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    })
    ..forward();
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic);

  // Small landing tilt, deterministic per card so the pile looks hand-placed.
  late final double _landingTilt =
      ((widget.flight.card.id.codeUnits.fold(0, (a, b) => a + b) % 7) - 3) * 0.03;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flight;
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value;
        final start = f.from.center;
        final end = f.to.center;
        // Quadratic bezier with a control point lifted above the straight line
        final control = Offset((start.dx + end.dx) / 2, math.min(start.dy, end.dy) - 60);
        final p = Offset(
          (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * control.dx + t * t * end.dx,
          (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * control.dy + t * t * end.dy,
        );
        final width = f.from.width + (f.to.width - f.from.width) * t;
        final height = width * 1.5;

        // Flip: the back narrows to nothing, then the face widens in.
        final showFace = !f.flip || t >= 0.5;
        final squash = f.flip ? (t < 0.5 ? 1 - t * 2 : t * 2 - 1) : 1.0;

        return Positioned(
          left: p.dx - width / 2,
          top: p.dy - height / 2,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: _landingTilt * t + math.sin(t * math.pi) * 0.12,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(squash.clamp(0.02, 1), 1, 1),
                child: PlayingCardView(
                  card: f.card.copyWith(faceUp: showFace),
                  width: width,
                  backStyle: f.backStyle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
