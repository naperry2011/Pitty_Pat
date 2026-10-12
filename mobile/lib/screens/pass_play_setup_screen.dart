import 'package:flutter/material.dart';

import '../settings/settings_store.dart';
import '../theme/tokens.dart';
import '../widgets/playful_background.dart';
import '../widgets/playful_button.dart';
import '../widgets/screen_header.dart';
import 'game_screen.dart';

// Pass-and-play setup: 2-4 people on one phone. Names and table size are
// remembered for next time.
class PassPlaySetupScreen extends StatefulWidget {
  const PassPlaySetupScreen({super.key});

  @override
  State<PassPlaySetupScreen> createState() => _PassPlaySetupScreenState();
}

class _PassPlaySetupScreenState extends State<PassPlaySetupScreen> {
  List<TextEditingController>? _names;
  int? _players;
  int? _matchTarget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _names ??= [
      for (final name in SettingsScope.of(context).settings.passNames) TextEditingController(text: name),
    ];
  }

  @override
  void dispose() {
    for (final c in _names ?? const <TextEditingController>[]) {
      c.dispose();
    }
    super.dispose();
  }

  void _start(SettingsStore store, int players, int matchTarget) {
    final all = resolvePassNames([for (final c in _names!) c.text], defaultPassNames.length);
    final seated = resolvePassNames([for (final c in _names!) c.text], players);
    store.update(store.settings.copyWith(passPlayers: players, passNames: all, matchTarget: matchTarget));
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => GameScreen.passAndPlay(playerNames: seated, matchTarget: matchTarget),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = SettingsScope.of(context);
    final players = _players ?? store.settings.passPlayers;
    final matchTarget = _matchTarget ?? store.settings.matchTarget;

    return Scaffold(
      body: PlayfulBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const ScreenHeader(title: 'Pass & Play'),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  'Play with friends on one phone. Pass it around each turn; '
                  'hands stay hidden until it\'s your go.',
                ),
              ),
              _Panel(
                title: 'How many players?',
                child: Row(
                  children: [
                    for (final count in passPlayerCounts) ...[
                      if (count != passPlayerCounts.first) const SizedBox(width: 8),
                      Expanded(
                        child: _Choice(
                          label: '$count',
                          selected: players == count,
                          onTap: () => setState(() => _players = count),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'Names',
                child: Column(
                  children: [
                    for (var i = 0; i < players; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextField(
                          controller: _names![i],
                          maxLength: maxPassNameLength,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: i == players - 1 ? TextInputAction.done : TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Player ${i + 1} name',
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: 'How long is the match?',
                child: Row(
                  children: [
                    for (final target in matchTargets) ...[
                      if (target != matchTargets.first) const SizedBox(width: 8),
                      Expanded(
                        child: _Choice(
                          label: 'First to $target',
                          selected: matchTarget == target,
                          onTap: () => setState(() => _matchTarget = target),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: PlayfulButton(
                  label: 'Deal!',
                  icon: Icons.play_arrow_rounded,
                  fontSize: 24,
                  onPressed: () => _start(store, players, matchTarget),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

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
            child,
          ],
        ),
      );
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: selected ? const LinearGradient(colors: [AppColors.coral, Color(0xFFFF8E8E)]) : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.85),
              boxShadow: AppShadows.card,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      );
}
