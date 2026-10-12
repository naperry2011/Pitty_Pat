import 'package:flutter/material.dart';

import '../cards/playing_card_view.dart';
import '../game/models.dart';
import '../profile/profile_store.dart';
import '../settings/settings_store.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/playful_background.dart';
import '../widgets/playful_button.dart';
import '../widgets/profile_badges.dart';
import 'daily_screen.dart';
import 'game_screen.dart';
import 'ladder_screen.dart';
import 'locker_screen.dart';
import 'pass_play_setup_screen.dart';
import 'settings_sheet.dart';
import 'setup_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _push(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final profile = ProfileScope.of(context);

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Badges shrink rather than overflow with large system text.
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    children: [
                                      LevelBadge(xp: profile.profile.xp),
                                      const SizedBox(width: 8),
                                      CoinBadge(coins: profile.profile.coins),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'Settings',
                              onPressed: () => showSettingsSheet(context),
                              icon: const Icon(Icons.settings_rounded),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const _CardFan(),
                        const SizedBox(height: 24),
                        Text(
                          'Pitty Pat',
                          style: TextStyle(
                            fontFamily: displayFontFamily(context),
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: AppColors.coralDeep,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Match the rank. Empty your hand. Win.',
                          textAlign: TextAlign.center,
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.ink.withValues(alpha: 0.75),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 16),
                        PlayfulButton(
                          label: 'Play',
                          icon: Icons.play_arrow_rounded,
                          fontSize: 24,
                          // First-timers get the tutorial; it hands off to setup when done.
                          onPressed: () => _push(
                            context,
                            SettingsScope.of(context).settings.tutorialDone
                                ? const SetupScreen()
                                : const GameScreen.tutorial(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        PlayfulButton(
                          label: 'Ladder',
                          icon: Icons.emoji_events_rounded,
                          primary: false,
                          fontSize: 18,
                          onPressed: () => _push(context, const LadderScreen()),
                        ),
                        const SizedBox(height: 12),
                        PlayfulButton(
                          label: 'Pass & Play',
                          icon: Icons.groups_rounded,
                          primary: false,
                          fontSize: 18,
                          onPressed: () => _push(context, const PassPlaySetupScreen()),
                        ),
                        const SizedBox(height: 14),
                        _DailyCard(
                          onTap: () => _push(context, const DailyScreen()),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MenuTile(
                                icon: Icons.style_rounded,
                                label: 'Locker',
                                onTap: () =>
                                    _push(context, const LockerScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MenuTile(
                                icon: Icons.bar_chart_rounded,
                                label: 'Stats',
                                onTap: () =>
                                    _push(context, const StatsScreen()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MenuTile(
                                icon: Icons.help_outline_rounded,
                                label: 'How to play',
                                onTap: () => showHowToPlaySheet(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = ProfileScope.of(context);
    final done = store.dailyDoneToday;
    final streak = store.dailyStreak;

    return Semantics(
      container: true,
      button: true,
      label:
          'Daily challenge, ${done ? 'done for today' : 'ready'}, $streak day streak',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: done
                  ? const [Color(0xFFB8D4E3), Color(0xFFE6E6FA)]
                  : const [AppColors.gold, AppColors.sunny],
            ),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.calendar_today_rounded,
                color: AppColors.ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: TextStyle(
                        fontFamily: displayFontFamily(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      done
                          ? 'Done for today'
                          : 'Same deal for everyone. Ready!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.coralDeep,
              ),
              Text(
                '$streak',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.coralDeep),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CardFan extends StatelessWidget {
  const _CardFan();

  static const _cards = [
    (
      PlayingCard(suit: Suit.hearts, rank: Rank.ace, faceUp: true),
      -0.28,
      -46.0,
    ),
    (PlayingCard(suit: Suit.spades, rank: Rank.ace), 0.0, 0.0),
    (PlayingCard(suit: Suit.spades, rank: Rank.ace, faceUp: true), 0.28, 46.0),
  ];

  @override
  Widget build(BuildContext context) {
    final back = SettingsScope.of(context).settings.cardBack;

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final (card, angle, dx) in _cards)
            Transform.translate(
              offset: Offset(dx, dx.abs() * 0.15),
              child: Transform.rotate(
                angle: angle,
                child: PlayingCardView(card: card, width: 90, backStyle: back),
              ),
            ),
        ],
      ),
    );
  }
}
