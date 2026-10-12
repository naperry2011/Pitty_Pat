import '../game/ai_player.dart';

// Pure progression rules: levels and match rewards.

/// Total XP needed to reach [level] (level 1 starts at 0; 2 at 100; 3 at 300; 4 at 600...).
int xpForLevel(int level) => 50 * (level - 1) * level;

int levelForXp(int xp) {
  var level = 1;
  while (xpForLevel(level + 1) <= xp) {
    level++;
  }
  return level;
}

/// 0..1 progress from the current level toward the next.
double levelProgress(int xp) {
  final level = levelForXp(xp);
  final floor = xpForLevel(level);
  return (xp - floor) / (xpForLevel(level + 1) - floor);
}

class MatchOutcome {
  const MatchOutcome({
    required this.difficulty,
    required this.matchTarget,
    required this.won,
    required this.roundsWon,
    required this.roundsLost,
    this.isDaily = false,
    this.opponents = 1,
  });

  final AIDifficulty difficulty;
  final int matchTarget;
  final bool won;
  final int roundsWon;
  final int roundsLost;
  final bool isDaily;
  final int opponents; // computer opponents at the table
}

class Reward {
  const Reward({required this.coins, required this.xp});
  final int coins;
  final int xp;

  Reward operator +(Reward o) => Reward(coins: coins + o.coins, xp: xp + o.xp);
}

const _winCoins = {AIDifficulty.easy: 10, AIDifficulty.medium: 20, AIDifficulty.hard: 35};
const _lossCoins = {AIDifficulty.easy: 3, AIDifficulty.medium: 5, AIDifficulty.hard: 8};
const _xpMultiplier = {AIDifficulty.easy: 1.0, AIDifficulty.medium: 1.5, AIDifficulty.hard: 2.0};
// Bigger tables are harder to win, so they pay more.
const _tableMultiplier = {1: 1.0, 2: 1.5, 3: 2.0};

/// Coins scale with match length (first to 5 is the baseline); XP comes from
/// rounds won plus a win bonus. Both scale with difficulty and table size.
Reward matchReward(MatchOutcome o) {
  if (o.isDaily) {
    return Reward(coins: o.won ? 40 : 15, xp: o.won ? 60 : 20);
  }
  final lengthScale = o.matchTarget / 5;
  final table = _tableMultiplier[o.opponents] ?? 1.0;
  final coins = ((o.won ? _winCoins : _lossCoins)[o.difficulty]! * lengthScale * table).round();
  final m = _xpMultiplier[o.difficulty]! * table;
  final xp = ((o.roundsWon * 10 + (o.won ? 25 : 5)) * m).round();
  return Reward(coins: coins, xp: xp);
}

/// Daily streak bonus: +5 coins per streak day, capped at +50.
int dailyStreakBonus(int streak) => (streak * 5).clamp(0, 50);
