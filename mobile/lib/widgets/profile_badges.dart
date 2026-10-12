import 'package:flutter/material.dart';

import '../profile/progression.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key, required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: '$coins coins',
        excludeSemantics: true,
        child: _Pill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 20),
              const SizedBox(width: 4),
              Text('$coins', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            ],
          ),
        ),
      );
}

class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final level = levelForXp(xp);
    return Semantics(
      container: true,
      label: 'Level $level, ${(levelProgress(xp) * 100).round()} percent to next level',
      excludeSemantics: true,
      child: _Pill(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: levelProgress(xp),
                    strokeWidth: 3,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: AppColors.coral,
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                      fontFamily: displayFontFamily(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text('Level', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppShadows.card,
        ),
        child: child,
      );
}
