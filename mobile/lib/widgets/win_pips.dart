import 'package:flutter/material.dart';

// Round-win pips: one dot per round needed, filled per wins so far.
class WinPips extends StatelessWidget {
  const WinPips({super.key, required this.wins, required this.target, required this.color});

  final int wins;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: '$wins of $target rounds won',
        excludeSemantics: true,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 3,
          runSpacing: 3,
          children: [
            for (var i = 0; i < target; i++)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < wins ? color : const Color(0xFFD1D5DB),
                ),
              ),
          ],
        ),
      );
}

class ScoreChip extends StatelessWidget {
  const ScoreChip({
    super.key,
    required this.label,
    required this.wins,
    required this.target,
    required this.color,
  });

  final String label;
  final int wins;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 58),
              child: WinPips(wins: wins, target: target, color: color),
            ),
          ],
        ),
      );
}
