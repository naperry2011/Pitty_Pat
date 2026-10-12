import 'package:flutter/material.dart';

import '../game/personalities.dart';
import '../profile/achievements.dart';
import '../profile/daily.dart';
import '../profile/ladder.dart';
import '../profile/profile_store.dart';
import '../profile/progression.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/playful_background.dart';
import '../widgets/screen_header.dart';
import 'setup_screen.dart' show difficultyOptions;

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProfileScope.of(context);
    final p = store.profile;
    final level = levelForXp(p.xp);
    final toNext = xpForLevel(level + 1) - p.xp;

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const ScreenHeader(title: 'Stats'),
              const SizedBox(height: 8),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level $level', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: levelProgress(p.xp),
                        minHeight: 10,
                        backgroundColor: const Color(0xFFE5E7EB),
                        color: AppColors.coral,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${p.xp} XP  ·  $toNext XP to level ${level + 1}',
                        style: const TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Tile(label: 'Win streak', value: '${p.currentWinStreak}')),
                  const SizedBox(width: 10),
                  Expanded(child: _Tile(label: 'Best streak', value: '${p.bestWinStreak}')),
                  const SizedBox(width: 10),
                  Expanded(child: _Tile(label: 'Best daily', value: '${bestDailyStreak(p.dailyCompleted)}')),
                ],
              ),
              const SizedBox(height: 12),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('By difficulty', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    for (final (d, label, _) in difficultyOptions) ...[
                      Builder(builder: (context) {
                        final s = p.statsFor(d);
                        return Row(
                          children: [
                            SizedBox(
                              width: 64,
                              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Expanded(
                              child: Text(
                                '${s.matchesWon}/${s.matchesPlayed} matches  ·  ${s.roundsWon}/${s.roundsPlayed} rounds',
                                style: const TextStyle(color: Color(0xFF4B5563)),
                              ),
                            ),
                            Text(
                              s.matchesPlayed == 0 ? '-' : '${(s.matchWinRate * 100).round()}%',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coralDeep),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Head to head', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    for (final name in ladderOrder) ...[
                      Builder(builder: (context) {
                        final r = p.rivals[name];
                        return Semantics(
                          container: true,
                          label: r == null || r.played == 0
                              ? '$name, not played yet'
                              : '$name, ${r.won} wins, ${r.lost} losses',
                          excludeSemantics: true,
                          child: Row(
                            children: [
                              CircleAvatar(radius: 6, backgroundColor: personalityByName(name).color),
                              const SizedBox(width: 8),
                              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
                              Text(
                                r == null || r.played == 0 ? '-' : '${r.won}-${r.lost}',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coralDeep),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements  ${p.achievements.length}/${achievements.length}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    for (final a in achievements)
                      _AchievementRow(achievement: a, earned: p.achievements.contains(a.id)),
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

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement, required this.earned});

  final Achievement achievement;
  final bool earned;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        label: '${achievement.title}, ${earned ? 'earned' : 'locked'}. ${achievement.description}',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                earned ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
                color: earned ? AppColors.gold : const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: earned ? AppColors.ink : const Color(0xFF6B7280),
                      ),
                    ),
                    Text(achievement.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Text('+${achievement.coins}', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => _Panel(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: displayFontFamily(context),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: child,
      );
}
