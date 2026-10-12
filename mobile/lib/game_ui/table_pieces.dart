import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cards/card_back.dart';
import '../cards/playing_card_view.dart';
import '../game/models.dart';
import '../theme/tokens.dart';

// Ports of Hand.tsx, Deck.tsx and DiscardPile.tsx.

// Cards are absolutely positioned so the hand closes up smoothly when one
// leaves, and each new deal flies in with a stagger (Hand.tsx layout + deal-in).
class HandView extends StatelessWidget {
  const HandView({
    super.key,
    required this.cards,
    required this.cardWidth,
    required this.backStyle,
    this.faceDown = false,
    this.playableIds = const {},
    this.selectedId,
    this.onCardTap,
    this.dealId = 0,
    this.dealFromAbove = true,
    this.animate = true,
    this.keyFor,
    this.gap,
  });

  final List<PlayingCard> cards;
  final double cardWidth;
  final CardBackStyle backStyle;
  final bool faceDown;
  final Set<String> playableIds;
  final String? selectedId;
  final void Function(String cardId)? onCardTap;
  // Changes on every new deal so the deal-in animation replays.
  final int dealId;
  final bool dealFromAbove;
  final bool animate;
  // Lets the game screen measure where a card sat before it flew away.
  final GlobalKey Function(String cardId)? keyFor;
  // Space between cards; negative overlaps them (crowded opponent seats).
  final double? gap;

  static const _reflow = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    final gap = this.gap ?? (faceDown ? 4.0 : 8.0);
    final lift = faceDown ? 0.0 : 24.0; // room for the selected lift + TAP TO PLAY pill
    final height = cardWidth * 1.5 + lift;

    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, box) {
        final total = cards.length * cardWidth + math.max(0, cards.length - 1) * gap;
        final start = (box.maxWidth - total) / 2;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < cards.length; i++)
              AnimatedPositioned(
                key: ValueKey(cards[i].id),
                duration: animate ? _reflow : Duration.zero,
                curve: Curves.easeOutCubic,
                left: start + i * (cardWidth + gap),
                top: lift,
                child: _DealIn(
                  key: ValueKey(dealId),
                  delay: GameTimingUi.dealStagger * i,
                  fromAbove: dealFromAbove,
                  animate: animate,
                  child: KeyedSubtree(
                    key: keyFor?.call(cards[i].id),
                    child: PlayingCardView(
                      card: faceDown ? cards[i].copyWith(faceUp: false) : cards[i],
                      width: cardWidth,
                      backStyle: backStyle,
                      isPlayable: playableIds.contains(cards[i].id),
                      isSelected: selectedId == cards[i].id,
                      onTap: onCardTap == null ? null : () => onCardTap!(cards[i].id),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

abstract final class GameTimingUi {
  static const dealStagger = Duration(milliseconds: 80);
  static const dealDuration = Duration(milliseconds: 420);
}

class _DealIn extends StatefulWidget {
  const _DealIn({
    super.key,
    required this.delay,
    required this.fromAbove,
    required this.animate,
    required this.child,
  });

  final Duration delay;
  final bool fromAbove;
  final bool animate;
  final Widget child;

  @override
  State<_DealIn> createState() => _DealInState();
}

class _DealInState extends State<_DealIn> with SingleTickerProviderStateMixin {
  // The stagger delay is folded into one controller (no timers left behind).
  late final Duration _total = widget.delay + GameTimingUi.dealDuration;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _total,
    value: widget.animate ? 0 : 1,
  );
  late final double _start = widget.delay.inMicroseconds / _total.inMicroseconds;
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Interval(_start, 1, curve: Curves.easeOutBack));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Interval(_start, 1, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (context, child) {
          final t = _t.value;
          return Opacity(
            opacity: _fade.value.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, (1 - t) * (widget.fromAbove ? -120 : 120)),
              child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
            ),
          );
        },
      );
}

class DeckView extends StatelessWidget {
  const DeckView({
    super.key,
    required this.count,
    required this.cardWidth,
    required this.backStyle,
    this.onTap,
  });

  final int count;
  final double cardWidth;
  final CardBackStyle backStyle;
  final VoidCallback? onTap;

  static const _back = PlayingCard(suit: Suit.spades, rank: Rank.ace);

  @override
  Widget build(BuildContext context) {
    final layers = math.min(3, count);
    final canTap = onTap != null && count > 0;

    return Semantics(
      container: true,
      button: canTap,
      label: 'Draw pile, $count cards',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: canTap ? onTap : null,
        child: SizedBox(
          width: cardWidth + 6,
          height: cardWidth * 1.5 + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (count == 0)
                Container(
                  width: cardWidth,
                  height: cardWidth * 1.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: AppColors.cream.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              // Glow sits behind the stack: a shadow on a transparent box also
              // fills its interior, which tinted the top card.
              if (canTap)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: cardWidth + 4,
                    height: cardWidth * 1.5 + 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      boxShadow: const [BoxShadow(color: Color(0x99FFE66D), blurRadius: 18, spreadRadius: 2)],
                    ),
                  ),
                ),
              for (var i = 0; i < layers; i++)
                Positioned(
                  left: (layers - 1 - i) * 2.0,
                  top: (layers - 1 - i) * 2.0,
                  child: PlayingCardView(card: _back, width: cardWidth, backStyle: backStyle),
                ),
              if (canTap)
                Positioned(
                  left: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: cardWidth,
                      height: cardWidth * 1.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: AppColors.sunny, width: 3),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -8,
                bottom: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscardPileView extends StatelessWidget {
  const DiscardPileView({
    super.key,
    required this.cards,
    required this.cardWidth,
    this.hiddenId,
  });

  final List<PlayingCard> cards;
  final double cardWidth;
  // A card still flying toward the pile; shown by the flight overlay instead.
  final String? hiddenId;

  // Deterministic tilt from the card id so the pile looks hand-placed.
  static double _tilt(PlayingCard c) => ((c.id.codeUnits.fold(0, (a, b) => a + b) % 9) - 4) * 0.02;

  @override
  Widget build(BuildContext context) {
    final shown = cards.where((c) => c.id != hiddenId).toList();
    final visible = shown.length <= 2 ? shown : shown.sublist(shown.length - 2);

    return Semantics(
      container: true,
      label: cards.isEmpty ? 'Discard pile, empty' : 'Discard pile, top card ${cards.last.rank.label} of ${cards.last.suit.name}',
      excludeSemantics: true,
      child: SizedBox(
        width: cardWidth + 6,
        height: cardWidth * 1.5 + 6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final card in visible)
              Transform.rotate(
                key: ValueKey(card.id),
                angle: identical(card, visible.last) ? 0 : _tilt(card),
                child: PlayingCardView(card: card, width: cardWidth),
              ),
          ],
        ),
      ),
    );
  }
}
