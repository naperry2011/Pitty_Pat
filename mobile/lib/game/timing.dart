// Mirrors lib/timing.ts.
abstract final class GameTiming {
  static const endTurnDelay = Duration(milliseconds: 400); // action resolves -> turn passes
  static const aiThinkDelay = Duration(milliseconds: 1200); // before the AI acts
  static const dealStagger = Duration(milliseconds: 80); // between dealt cards
}
