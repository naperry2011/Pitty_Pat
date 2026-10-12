import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/cards/card_back.dart';
import 'package:pitty_pat/cards/card_face.dart';
import 'package:pitty_pat/cards/playing_card_view.dart';
import 'package:pitty_pat/cards/suit_shapes.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/models.dart';

// Pumped without the app theme so no font fetching happens in tests.
Widget _host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  test('suit paths are centered and fit their requested size', () {
    for (final suit in Suit.values) {
      final b = suitPath(suit, 40).getBounds();
      expect(b.width, lessThanOrEqualTo(40.5), reason: suit.name);
      expect(b.height, lessThanOrEqualTo(40.5), reason: suit.name);
      expect(b.center.dx.abs(), lessThan(2), reason: suit.name);
      expect(b.center.dy.abs(), lessThan(4), reason: suit.name);
    }
  });

  testWidgets('every card face renders with an accessible label', (tester) async {
    for (final card in createDeck()) {
      await tester.pumpWidget(_host(SizedBox(
        width: 80,
        height: 120,
        child: CardFace(rank: card.rank, suit: card.suit),
      )));
      expect(tester.takeException(), isNull, reason: card.id);
      expect(find.bySemanticsLabel('${card.rank.label} of ${card.suit.name}'), findsOneWidget);
    }
  });

  testWidgets('rank text is centered on its anchor inside the card', (tester) async {
    await tester.pumpWidget(_host(const SizedBox(
      width: 240,
      height: 360,
      child: CardFace(rank: Rank.king, suit: Suit.spades),
    )));
    final card = tester.getRect(find.byType(CardFace));
    final centers = find.text('K').evaluate().map((e) {
      final box = e.renderObject! as RenderBox;
      // Transform the local center so the rotated corner copy is measured correctly.
      final center = box.localToGlobal(box.size.center(Offset.zero));
      expect(card.contains(center), isTrue);
      return center.dx - card.left;
    }).toList();
    // Corner index (x=26), its rotated copy (x=214), and the large face letter (x=120) twice.
    expect(centers.map((x) => x.round()).toList()..sort(), [26, 120, 120, 214]);
  });

  testWidgets('every card back style renders', (tester) async {
    for (final style in CardBackStyle.values) {
      await tester.pumpWidget(_host(SizedBox(width: 80, height: 120, child: CardBack(style: style))));
      expect(tester.takeException(), isNull, reason: style.name);
    }
  });

  testWidgets('selected card shows the tap-to-play pill and forwards taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(PlayingCardView(
      card: const PlayingCard(suit: Suit.spades, rank: Rank.five, faceUp: true),
      width: 80,
      isPlayable: true,
      isSelected: true,
      onTap: () => taps++,
    )));
    expect(find.text('TAP TO PLAY'), findsOneWidget);
    await tester.tap(find.byType(PlayingCardView));
    expect(taps, 1);
  });

  testWidgets('face-down cards render the back, not the face', (tester) async {
    await tester.pumpWidget(_host(const PlayingCardView(
      card: PlayingCard(suit: Suit.hearts, rank: Rank.ace),
      width: 80,
    )));
    expect(find.byType(CardBack), findsOneWidget);
    expect(find.byType(CardFace), findsNothing);
  });
}
