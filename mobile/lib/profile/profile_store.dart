import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cosmetics/catalog.dart';
import '../game/ai_player.dart';
import 'achievements.dart';
import 'daily.dart';
import 'player_profile.dart';
import 'progression.dart';

class MatchSummary {
  const MatchSummary({
    required this.reward,
    required this.streakBonus,
    required this.levelBefore,
    required this.levelAfter,
    required this.unlocked,
  });

  final Reward reward; // match reward, before achievement coins
  final int streakBonus; // daily streak coins
  final int levelBefore;
  final int levelAfter;
  final List<Achievement> unlocked;

  bool get leveledUp => levelAfter > levelBefore;
  int get totalCoins => reward.coins + streakBonus + unlocked.fold(0, (a, x) => a + x.coins);
}

DifficultyStats _bump(DifficultyStats s, {int matches = 0, int matchWins = 0, int rounds = 0, int roundWins = 0}) =>
    s.copyWith(
      matchesPlayed: s.matchesPlayed + matches,
      matchesWon: s.matchesWon + matchWins,
      roundsPlayed: s.roundsPlayed + rounds,
      roundsWon: s.roundsWon + roundWins,
    );

/// Pure: a finished round. Daily challenge rounds don't count toward difficulty stats.
PlayerProfile applyRound(PlayerProfile p, AIDifficulty d, {required bool won, bool isDaily = false}) {
  if (isDaily) return p;
  return p.copyWith(stats: {
    ...p.stats,
    d: _bump(p.statsFor(d), rounds: 1, roundWins: won ? 1 : 0),
  });
}

/// Pure: a finished match. Returns the new profile and what to show the player.
/// A daily challenge only pays out the first time it's completed that day.
(PlayerProfile, MatchSummary?) applyMatch(PlayerProfile p, MatchOutcome o, DateTime today) {
  final levelBefore = levelForXp(p.xp);
  var next = p;
  var streakBonus = 0;

  if (o.isDaily) {
    final key = dateKey(today);
    if (p.dailyCompleted.contains(key)) return (p, null);
    next = next.copyWith(
      dailyCompleted: {...p.dailyCompleted, key},
      dailyWon: o.won ? {...p.dailyWon, key} : p.dailyWon,
    );
    streakBonus = dailyStreakBonus(currentDailyStreak(next.dailyCompleted, today));
  } else {
    final streak = o.won ? p.currentWinStreak + 1 : 0;
    next = next.copyWith(
      stats: {
        ...p.stats,
        o.difficulty: _bump(p.statsFor(o.difficulty), matches: 1, matchWins: o.won ? 1 : 0),
      },
      currentWinStreak: streak,
      bestWinStreak: streak > p.bestWinStreak ? streak : p.bestWinStreak,
    );
  }

  final reward = matchReward(o);
  next = next.copyWith(coins: next.coins + reward.coins + streakBonus, xp: next.xp + reward.xp);

  // One pass is enough: achievement coins never satisfy another achievement.
  final unlocked = newlyEarned(next, AchievementContext(lastMatch: o, today: today));
  next = next.copyWith(
    achievements: {...next.achievements, for (final a in unlocked) a.id},
    coins: next.coins + unlocked.fold<int>(0, (a, x) => a + x.coins),
  );

  return (
    next,
    MatchSummary(
      reward: reward,
      streakBonus: streakBonus,
      levelBefore: levelBefore,
      levelAfter: levelForXp(next.xp),
      unlocked: unlocked,
    ),
  );
}

enum PurchaseResult { purchased, alreadyOwned, notEnoughCoins, levelLocked }

/// Pure: buy a cosmetic with coins.
(PlayerProfile, PurchaseResult) applyPurchase(PlayerProfile p, Cosmetic item, DateTime today) {
  if (p.owned.contains(item.id)) return (p, PurchaseResult.alreadyOwned);
  if (levelForXp(p.xp) < item.minLevel) return (p, PurchaseResult.levelLocked);
  if (p.coins < item.price) return (p, PurchaseResult.notEnoughCoins);
  var next = p.copyWith(coins: p.coins - item.price, owned: {...p.owned, item.id});
  // Collector-style achievements can unlock from a purchase.
  final unlocked = newlyEarned(next, AchievementContext(today: today));
  next = next.copyWith(
    achievements: {...next.achievements, for (final a in unlocked) a.id},
    coins: next.coins + unlocked.fold<int>(0, (a, x) => a + x.coins),
  );
  return (next, PurchaseResult.purchased);
}

class ProfileStore extends ChangeNotifier {
  ProfileStore(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        _profile = _load(_prefs);

  static const _key = 'profile.v1';

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  PlayerProfile _profile;

  PlayerProfile get profile => _profile;
  DateTime get today => _now();
  int get level => levelForXp(_profile.xp);
  bool get dailyDoneToday => _profile.dailyCompleted.contains(dateKey(today));
  int get dailyStreak => currentDailyStreak(_profile.dailyCompleted, today);

  static PlayerProfile _load(SharedPreferences prefs) {
    PlayerProfile p;
    try {
      p = PlayerProfile.fromJson(jsonDecode(prefs.getString(_key) ?? 'null'));
    } catch (_) {
      p = const PlayerProfile();
    }
    // Free items are always owned, including ones added in later versions.
    return p.copyWith(owned: {...p.owned, ...starterCosmetics});
  }

  void recordRound(AIDifficulty d, {required bool won, bool isDaily = false}) =>
      _set(applyRound(_profile, d, won: won, isDaily: isDaily));

  MatchSummary? recordMatch(MatchOutcome o) {
    final (next, summary) = applyMatch(_profile, o, today);
    _set(next);
    return summary;
  }

  PurchaseResult buy(Cosmetic item) {
    final (next, result) = applyPurchase(_profile, item, today);
    _set(next);
    return result;
  }

  bool owns(String cosmeticId) => _profile.owned.contains(cosmeticId);

  // Debug-only testing aids; the asserts make them no-ops in release builds.
  void debugGrantCoins(int amount) {
    assert(() {
      _set(_profile.copyWith(coins: _profile.coins + amount));
      return true;
    }());
  }

  void debugGrantXp(int amount) {
    assert(() {
      _set(_profile.copyWith(xp: _profile.xp + amount));
      return true;
    }());
  }

  void debugReset() {
    assert(() {
      _set(PlayerProfile(owned: starterCosmetics));
      return true;
    }());
  }

  void _set(PlayerProfile next) {
    if (identical(next, _profile)) return;
    _profile = next;
    notifyListeners();
    // Persistence failure must not block play.
    _prefs.setString(_key, jsonEncode(next.toJson())).catchError((_) => false);
  }
}

class ProfileScope extends InheritedNotifier<ProfileStore> {
  const ProfileScope({super.key, required ProfileStore store, required super.child})
      : super(notifier: store);

  static ProfileStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfileScope>()!.notifier!;

  // Screens that can run without a profile (isolated widget tests) use this.
  static ProfileStore? maybeRead(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProfileScope>()?.notifier;

  // For event handlers that shouldn't subscribe to rebuilds.
  static ProfileStore read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ProfileScope>()!.notifier!;
}
