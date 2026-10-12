import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../cards/card_back.dart';
import '../cards/playing_card_view.dart';
import '../cosmetics/catalog.dart';
import '../game/models.dart';
import '../profile/profile_store.dart';
import '../settings/settings_store.dart';
import 'game_screen.dart';
import '../theme/tokens.dart';

Future<void> showSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.panel)),
      ),
      builder: (_) => const SettingsSheet(),
    );

Future<void> showHowToPlaySheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.panel)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HowToPlay(),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const GameScreen.tutorial()),
                    );
                  },
                  icon: const Icon(Icons.school_rounded),
                  label: const Text('Play the tutorial'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final store = SettingsScope.of(context);
    final s = store.settings;
    final profile = ProfileScope.maybeRead(context);
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Settings', style: text.headlineSmall),
            const SizedBox(height: 16),
            _Panel(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sound', style: TextStyle(fontWeight: FontWeight.w700)),
                    secondary: Icon(s.soundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded),
                    value: !s.soundMuted,
                    activeThumbColor: AppColors.coral,
                    onChanged: (on) => store.update(s.copyWith(soundMuted: !on)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Opponent chatter', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Speech bubbles from computer players'),
                    secondary: Icon(s.chatter ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded),
                    value: s.chatter,
                    activeThumbColor: AppColors.coral,
                    onChanged: (on) => store.update(s.copyWith(chatter: on)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Card back', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // Only owned backs; the rest are bought in the Locker.
                      for (final style in CardBackStyle.values)
                        if (profile?.owns(cardBackId(style)) ?? true)
                          _CardBackOption(
                            style: style,
                            selected: s.cardBack == style,
                            onTap: () => store.update(s.copyWith(cardBack: style)),
                          ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Unlock more backs, felts and win effects in the Locker.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Panel(child: HowToPlay()),
            // Compiled out of release builds (kDebugMode is a const false there).
            if (kDebugMode && profile != null) ...[
              const SizedBox(height: 12),
              _Panel(child: _DebugTools(profile: profile)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardBackOption extends StatelessWidget {
  const _CardBackOption({required this.style, required this.selected, required this.onTap});

  final CardBackStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        selected: selected,
        label: '${style.name} card back',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.card + 3),
              border: Border.all(color: selected ? AppColors.coral : Colors.transparent, width: 3),
            ),
            child: PlayingCardView(
              card: const PlayingCard(suit: Suit.spades, rank: Rank.ace),
              backStyle: style,
              width: 56,
            ),
          ),
        ),
      );
}

class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});

  static const _rules = [
    (AppColors.coral, 'Match the rank of the top discard card'),
    (AppColors.gold, 'No match? Draw from the deck'),
    (AppColors.mint, 'First to empty your hand wins the round'),
  ];

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How to play', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final (color, rule) in _rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: color),
                  const SizedBox(width: 10),
                  Expanded(child: Text(rule)),
                ],
              ),
            ),
        ],
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  // Material (not a colored box) so list tiles inside keep their ink ripples.
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.card,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      );
}

// Debug builds only: speeds up testing the Locker and level gates.
class _DebugTools extends StatelessWidget {
  const _DebugTools({required this.profile});

  final ProfileStore profile;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bug_report_rounded, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Expanded(
                child: Text('Debug tools (not in release builds)', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => profile.debugGrantCoins(1000),
                child: const Text('+1000 coins'),
              ),
              OutlinedButton(
                onPressed: () => profile.debugGrantXp(500),
                child: const Text('+500 XP'),
              ),
              OutlinedButton(
                onPressed: profile.debugReset,
                child: const Text('Reset profile'),
              ),
            ],
          ),
        ],
      );
}
