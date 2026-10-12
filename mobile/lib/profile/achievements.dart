import '../game/ai_player.dart';
import 'daily.dart';
import 'ladder.dart';
import 'player_profile.dart';
import 'progression.dart';

// Local achievements. Ids are stable so they can map 1:1 to Google Play Games
// / Game Center achievement ids later.
class Achievement {
  const Achievement(this.id, this.title, this.description, this.isEarned, {this.coins = 25});

  final String id;
  final String title;
  final String description;
  final bool Function(PlayerProfile p, AchievementContext ctx) isEarned;
  final int coins;
}

// Facts about the event that just happened (some achievements are about a single match).
class AchievementContext {
  const AchievementContext({this.lastMatch, required this.today});
  final MatchOutcome? lastMatch;
  final DateTime today;
}

int _totalRoundsWon(PlayerProfile p) => p.stats.values.fold(0, (a, s) => a + s.roundsWon);
int _totalMatchesWon(PlayerProfile p) => p.stats.values.fold(0, (a, s) => a + s.matchesWon);

final List<Achievement> achievements = [
  Achievement('first_win', 'First Pat', 'Win your first match',
      (p, _) => _totalMatchesWon(p) >= 1),
  Achievement('sharp_win', 'Sharp Shooter', 'Beat the Sharp computer in a match',
      (p, _) => (p.stats[AIDifficulty.hard]?.matchesWon ?? 0) >= 1),
  Achievement('sweep', 'Clean Sweep', 'Win a match of 3+ rounds without losing one',
      (p, c) {
    final m = c.lastMatch;
    return m != null && !m.isDaily && m.won && m.roundsLost == 0 && m.matchTarget >= 3;
  }, coins: 50),
  Achievement('streak_3', 'On a Roll', 'Win 3 matches in a row',
      (p, _) => p.bestWinStreak >= 3),
  Achievement('streak_10', 'Unstoppable', 'Win 10 matches in a row',
      (p, _) => p.bestWinStreak >= 10, coins: 100),
  Achievement('rounds_50', 'Card Shark', 'Win 50 rounds',
      (p, _) => _totalRoundsWon(p) >= 50, coins: 50),
  Achievement('daily_first', 'Daily Dealer', 'Complete a daily challenge',
      (p, _) => p.dailyCompleted.isNotEmpty),
  Achievement('daily_streak_7', 'Week of Pats', 'Complete the daily challenge 7 days in a row',
      (p, _) => bestDailyStreak(p.dailyCompleted) >= 7, coins: 100),
  Achievement('table_boss', 'Table Boss', 'Win a match at a full table of 4 players', (p, c) {
    final m = c.lastMatch;
    return m != null && !m.isDaily && m.won && m.opponents >= 3;
  }, coins: 50),
  Achievement('ladder_chill', 'Warming Up', 'Clear the three Chill rungs of the ladder',
      (p, _) => p.ladderCleared >= 3),
  Achievement('ladder_clever', 'Halfway Up', 'Clear the three Clever rungs of the ladder',
      (p, _) => p.ladderCleared >= 6, coins: 50),
  Achievement('ladder_top', 'Top of the Ladder', 'Beat Vince to finish the ladder',
      (p, _) => p.ladderCleared >= ladderOrder.length, coins: 150),
  Achievement('rivals_all', "Nobody's Safe", 'Beat every opponent at least once',
      (p, _) => ladderOrder.every((name) => (p.rivals[name]?.won ?? 0) >= 1), coins: 75),
  Achievement('level_5', 'Rising Star', 'Reach level 5',
      (p, _) => levelForXp(p.xp) >= 5),
  Achievement('collector', 'Collector', 'Own 8 cosmetics',
      (p, _) => p.owned.length >= 8, coins: 50),
];

Achievement achievementById(String id) => achievements.firstWhere((a) => a.id == id);

/// Achievements newly earned by [profile] that it hasn't unlocked yet.
List<Achievement> newlyEarned(PlayerProfile profile, AchievementContext ctx) => [
      for (final a in achievements)
        if (!profile.achievements.contains(a.id) && a.isEarned(profile, ctx)) a,
    ];
