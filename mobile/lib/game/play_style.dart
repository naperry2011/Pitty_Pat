import 'models.dart';
import 'timing.dart';

// How a named opponent plays (app-only; the web has a single "Computer").
// Playing a match always beats drawing, so style can only shape when the AI
// overlooks a match and how long it takes to move.

enum Trait {
  none,
  closer, // never misses with 2 or fewer cards left
  coasts, // gets careless while leading the match
  focused, // never misses while anyone else is down to one card
  steadies, // never misses while trailing in round wins
  tilts, // gets careless while trailing in round wins
}

class PlayStyle {
  const PlayStyle({
    required this.miss,
    this.thinkDelay = GameTiming.aiThinkDelay,
    this.trait = Trait.none,
  });

  final double miss; // base chance of overlooking a held match
  final Duration thinkDelay;
  final Trait trait;

  static const _swing = 0.2;

  /// Miss chance for [player] (an AI seat) right now.
  double missChanceFor(GameState s, Player player) {
    final others = s.players.where((p) => p.id != player.id);
    final bestOther = others.isEmpty
        ? 0
        : others.map((p) => p.wins).reduce((a, b) => a > b ? a : b);

    return switch (trait) {
      Trait.none => miss,
      Trait.closer => player.hand.length <= 2 ? 0 : miss,
      Trait.coasts =>
        player.wins > bestOther ? (miss + _swing).clamp(0, 1) : miss,
      Trait.focused => others.any((p) => p.hand.length == 1) ? 0 : miss,
      Trait.steadies => bestOther > player.wins ? 0 : miss,
      Trait.tilts =>
        bestOther > player.wins ? (miss + _swing).clamp(0, 1) : miss,
    };
  }
}
