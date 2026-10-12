import 'dart:typed_data';
import 'dart:ui';

import '../game/models.dart';

// Suits are drawn as vector paths instead of text glyphs: Android can render
// U+2660-2666 as color emoji, which breaks the card look.
// Each path is authored in a 100x100 box and centered on (0, 0) by [suitPath].

Path _heart() => Path()
  ..moveTo(50, 94)
  ..cubicTo(14, 66, 0, 46, 0, 28)
  ..cubicTo(0, 11, 12, 0, 27, 0)
  ..cubicTo(38, 0, 46, 7, 50, 17)
  ..cubicTo(54, 7, 62, 0, 73, 0)
  ..cubicTo(88, 0, 100, 11, 100, 28)
  ..cubicTo(100, 46, 86, 66, 50, 94)
  ..close();

Path _diamond() => Path()
  ..moveTo(50, 0)
  ..lineTo(86, 50)
  ..lineTo(50, 100)
  ..lineTo(14, 50)
  ..close();

Path _spade() => Path()
  ..moveTo(50, 0)
  ..cubicTo(32, 24, 0, 40, 0, 62)
  ..cubicTo(0, 77, 11, 87, 25, 87)
  ..cubicTo(35, 87, 43, 82, 46, 75)
  ..lineTo(40, 100)
  ..lineTo(60, 100)
  ..lineTo(54, 75)
  ..cubicTo(57, 82, 65, 87, 75, 87)
  ..cubicTo(89, 87, 100, 77, 100, 62)
  ..cubicTo(100, 40, 68, 24, 50, 0)
  ..close();

Path _club() => Path()
  ..addOval(Rect.fromCircle(center: const Offset(50, 25), radius: 23))
  ..addOval(Rect.fromCircle(center: const Offset(25, 60), radius: 23))
  ..addOval(Rect.fromCircle(center: const Offset(75, 60), radius: 23))
  ..addRect(const Rect.fromLTRB(38, 30, 62, 66))
  ..moveTo(46, 62)
  ..lineTo(40, 100)
  ..lineTo(60, 100)
  ..lineTo(54, 62)
  ..close();

final Map<Suit, Path> _unitPaths = {
  Suit.hearts: _heart(),
  Suit.diamonds: _diamond(),
  Suit.spades: _spade(),
  Suit.clubs: _club(),
};

/// Path for [suit] scaled to [size] and centered on the origin.
Path suitPath(Suit suit, double size) {
  final scale = size / 100;
  final matrix = Float64List.fromList([
    scale, 0, 0, 0, //
    0, scale, 0, 0, //
    0, 0, 1, 0, //
    -size / 2, -size / 2, 0, 1, //
  ]);
  return _unitPaths[suit]!.transform(matrix);
}

void drawSuit(Canvas canvas, Suit suit, Offset center, double size, Color color,
    {bool flipped = false}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  if (flipped) canvas.rotate(3.141592653589793);
  canvas.drawPath(suitPath(suit, size), Paint()..color = color);
  canvas.restore();
}
