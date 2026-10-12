import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme/tokens.dart';
import 'card_back.dart';
import 'card_face.dart';

// Port of components/game/Card.tsx. Size comes from the parent via [width];
// height follows the 2:3 card ratio.
class PlayingCardView extends StatelessWidget {
  const PlayingCardView({
    super.key,
    required this.card,
    required this.width,
    this.backStyle = CardBackStyle.classic,
    this.isPlayable = false,
    this.isSelected = false,
    this.onTap,
  });

  final PlayingCard card;
  final double width;
  final CardBackStyle backStyle;
  final bool isPlayable;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.5;
    final radius = BorderRadius.circular(AppRadii.card * width / 80);

    final Widget art = card.faceUp
        ? CardFace(rank: card.rank, suit: card.suit)
        : CardBack(style: backStyle);

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: width,
      height: height,
      transform: Matrix4.translationValues(0, isSelected ? -12 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isSelected ? AppShadows.selected : AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            art,
            if (card.faceUp && onTap != null && !isPlayable)
              const ColoredBox(color: Color(0x339CA3AF)),
            if (card.faceUp && (isPlayable || isSelected))
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: isSelected ? null : AppColors.playable.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isSelected ? AppColors.selected : AppColors.playable,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          body,
          if (isSelected)
            Positioned(
              // Clears the 12px selection lift so the corner rank stays visible.
              top: -34,
              child: _TapToPlayPill(fontSize: (width * 0.11).clamp(8, 12)),
            ),
        ],
      ),
    );
  }
}

class _TapToPlayPill extends StatelessWidget {
  const _TapToPlayPill({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.selected,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFEAB308)),
          boxShadow: AppShadows.raised,
        ),
        child: Text(
          'TAP TO PLAY',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
        ),
      );
}
