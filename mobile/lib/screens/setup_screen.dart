import 'package:flutter/material.dart';

import '../game/ai_player.dart';
import '../settings/settings_store.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/playful_background.dart';
import '../widgets/playful_button.dart';
import 'game_screen.dart';

// Port of components/game/SetupScreen.tsx.
const difficultyOptions = [
  (AIDifficulty.easy, 'Chill', 'Relaxed opponent'),
  (AIDifficulty.medium, 'Clever', 'Thinks it through'),
  (AIDifficulty.hard, 'Sharp', 'Plays to win'),
];

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  AIDifficulty? _difficulty;
  int? _matchTarget;
  int? _opponents;

  @override
  Widget build(BuildContext context) {
    final store = SettingsScope.of(context);
    final difficulty = _difficulty ?? store.settings.difficulty;
    final matchTarget = _matchTarget ?? store.settings.matchTarget;
    final opponents = _opponents ?? store.settings.opponents;

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton(onPressed: () => Navigator.of(context).maybePop()),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          'Game Setup',
                          style: TextStyle(
                            fontFamily: displayFontFamily(context),
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.coralDeep,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _Group(
                          title: 'How tough is the computer?',
                          children: [
                            for (final (value, label, description) in difficultyOptions)
                              _OptionTile(
                                label: label,
                                description: description,
                                selected: difficulty == value,
                                onTap: () => setState(() => _difficulty = value),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Group(
                          title: 'How long is the match?',
                          children: [
                            for (final target in matchTargets)
                              _OptionTile(
                                label: 'First to $target',
                                selected: matchTarget == target,
                                onTap: () => setState(() => _matchTarget = target),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Group(
                          title: 'How many opponents?',
                          children: [
                            for (final count in opponentCounts)
                              _OptionTile(
                                label: '$count',
                                description: count == 1 ? 'Head to head' : '${count + 1}-player table',
                                selected: opponents == count,
                                onTap: () => setState(() => _opponents = count),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        PlayfulButton(
                          label: 'Play!',
                          icon: Icons.play_arrow_rounded,
                          fontSize: 24,
                          onPressed: () {
                            store.update(store.settings.copyWith(
                              difficulty: difficulty,
                              matchTarget: matchTarget,
                              opponents: opponents,
                            ));
                            Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                              builder: (_) => GameScreen(
                                difficulty: difficulty,
                                matchTarget: matchTarget,
                                opponents: opponents,
                              ),
                            ));
                          },
                        ),
                      ],
                    ),
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

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: children[i]),
                ],
              ],
            ),
          ],
        ),
      );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
  });

  final String label;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: selected ? 1.05 : 1,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: selected
                    ? const LinearGradient(colors: [AppColors.coral, Color(0xFFFF8E8E)])
                    : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.85),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
