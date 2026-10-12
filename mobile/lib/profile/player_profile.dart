import '../game/ai_player.dart';

class DifficultyStats {
  const DifficultyStats({
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.roundsPlayed = 0,
    this.roundsWon = 0,
  });

  final int matchesPlayed;
  final int matchesWon;
  final int roundsPlayed;
  final int roundsWon;

  double get matchWinRate => matchesPlayed == 0 ? 0 : matchesWon / matchesPlayed;

  DifficultyStats copyWith({int? matchesPlayed, int? matchesWon, int? roundsPlayed, int? roundsWon}) =>
      DifficultyStats(
        matchesPlayed: matchesPlayed ?? this.matchesPlayed,
        matchesWon: matchesWon ?? this.matchesWon,
        roundsPlayed: roundsPlayed ?? this.roundsPlayed,
        roundsWon: roundsWon ?? this.roundsWon,
      );

  Map<String, Object> toJson() => {
        'mp': matchesPlayed,
        'mw': matchesWon,
        'rp': roundsPlayed,
        'rw': roundsWon,
      };

  static DifficultyStats fromJson(Object? json) {
    if (json is! Map) return const DifficultyStats();
    int read(String k) => (json[k] is int && (json[k] as int) >= 0) ? json[k] as int : 0;
    return DifficultyStats(
      matchesPlayed: read('mp'),
      matchesWon: read('mw'),
      roundsPlayed: read('rp'),
      roundsWon: read('rw'),
    );
  }
}

// Everything the player earns. Persisted as one JSON document; every field is
// validated on load so a corrupt or older save never crashes the app.
class PlayerProfile {
  const PlayerProfile({
    this.coins = 0,
    this.xp = 0,
    this.stats = const {},
    this.currentWinStreak = 0,
    this.bestWinStreak = 0,
    this.owned = const {},
    this.dailyCompleted = const {},
    this.dailyWon = const {},
    this.achievements = const {},
  });

  final int coins;
  final int xp;
  final Map<AIDifficulty, DifficultyStats> stats;
  final int currentWinStreak; // consecutive non-daily match wins
  final int bestWinStreak;
  final Set<String> owned; // cosmetic ids
  final Set<String> dailyCompleted; // date keys
  final Set<String> dailyWon; // date keys
  final Set<String> achievements; // achievement ids

  static const schemaVersion = 1;

  DifficultyStats statsFor(AIDifficulty d) => stats[d] ?? const DifficultyStats();

  PlayerProfile copyWith({
    int? coins,
    int? xp,
    Map<AIDifficulty, DifficultyStats>? stats,
    int? currentWinStreak,
    int? bestWinStreak,
    Set<String>? owned,
    Set<String>? dailyCompleted,
    Set<String>? dailyWon,
    Set<String>? achievements,
  }) =>
      PlayerProfile(
        coins: coins ?? this.coins,
        xp: xp ?? this.xp,
        stats: stats ?? this.stats,
        currentWinStreak: currentWinStreak ?? this.currentWinStreak,
        bestWinStreak: bestWinStreak ?? this.bestWinStreak,
        owned: owned ?? this.owned,
        dailyCompleted: dailyCompleted ?? this.dailyCompleted,
        dailyWon: dailyWon ?? this.dailyWon,
        achievements: achievements ?? this.achievements,
      );

  Map<String, Object> toJson() => {
        'v': schemaVersion,
        'coins': coins,
        'xp': xp,
        'stats': {for (final e in stats.entries) e.key.name: e.value.toJson()},
        'streak': currentWinStreak,
        'bestStreak': bestWinStreak,
        'owned': owned.toList()..sort(),
        'daily': dailyCompleted.toList()..sort(),
        'dailyWon': dailyWon.toList()..sort(),
        'achievements': achievements.toList()..sort(),
      };

  static PlayerProfile fromJson(Object? json) {
    if (json is! Map) return const PlayerProfile();
    int count(String k) => (json[k] is int && (json[k] as int) >= 0) ? json[k] as int : 0;
    Set<String> strings(String k) =>
        json[k] is List ? {for (final v in json[k] as List) if (v is String) v} : <String>{};
    final rawStats = json['stats'];

    return PlayerProfile(
      coins: count('coins'),
      xp: count('xp'),
      stats: {
        if (rawStats is Map)
          for (final d in AIDifficulty.values)
            if (rawStats.containsKey(d.name)) d: DifficultyStats.fromJson(rawStats[d.name]),
      },
      currentWinStreak: count('streak'),
      bestWinStreak: count('bestStreak'),
      owned: strings('owned'),
      dailyCompleted: strings('daily'),
      dailyWon: strings('dailyWon'),
      achievements: strings('achievements'),
    );
  }
}
