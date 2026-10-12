import 'package:flutter/material.dart';

import '../game/personalities.dart';
import '../profile/ladder.dart';
import '../profile/profile_store.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/playful_background.dart';
import '../widgets/screen_header.dart';
import 'game_screen.dart';
import 'setup_screen.dart' show difficultyOptions;

// Climb through every named opponent, 1v1, first to 3. Beaten rungs can be
// replayed; only the next rung pays the clear bonus.
class LadderScreen extends StatelessWidget {
  const LadderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cleared = ProfileScope.of(context).profile.ladderCleared;
    final done = cleared >= ladderOrder.length;

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  children: [
                    const ScreenHeader(title: 'Ladder'),
                    const SizedBox(height: 4),
                    Text(
                      done
                          ? 'You beat everyone. Replay any rung to keep sharp.'
                          : 'Beat each opponent, first to $ladderMatchTarget, to unlock the next. '
                              '$cleared of ${ladderOrder.length} cleared.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              // Reversed: the first rung sits at the bottom and the list opens
              // there, so the climb reads upward and starts in view.
              Expanded(
                child: ListView(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    for (var rung = 0; rung < ladderOrder.length; rung++) ...[
                      _Rung(
                        rung: rung,
                        persona: personalityByName(ladderOrder[rung]),
                        state: rung < cleared
                            ? _RungState.cleared
                            : rung == cleared
                            ? _RungState.next
                            : _RungState.locked,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RungState { cleared, next, locked }

class _Rung extends StatelessWidget {
  const _Rung({required this.rung, required this.persona, required this.state});

  final int rung;
  final Personality persona;
  final _RungState state;

  @override
  Widget build(BuildContext context) {
    final locked = state == _RungState.locked;
    final tier = difficultyOptions.firstWhere((o) => o.$1 == persona.difficulty).$2;
    final status = switch (state) {
      _RungState.cleared => 'cleared, tap to replay',
      _RungState.next => 'next up, +${ladderBonus(rung)} coins',
      _RungState.locked => 'locked',
    };

    return Semantics(
      container: true,
      button: !locked,
      label: 'Rung ${rung + 1}, ${persona.name}, $tier. ${persona.tagline}. $status',
      excludeSemantics: true,
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Material(
          color: Colors.white.withValues(alpha: state == _RungState.next ? 0.95 : 0.8),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: locked
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => GameScreen.ladder(rung: rung)),
                    ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: state == _RungState.next ? AppColors.coral : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: persona.color,
                    child: Text(
                      persona.name[0],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          persona.name,
                          style: TextStyle(
                            fontFamily: displayFontFamily(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '$tier  ·  ${persona.tagline}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  switch (state) {
                    _RungState.cleared => const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 28),
                    _RungState.next => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${ladderBonus(rung)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    _RungState.locked => const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF)),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
