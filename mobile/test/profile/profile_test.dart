import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/cards/card_back.dart';
import 'package:pitty_pat/cosmetics/catalog.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/profile/daily.dart';
import 'package:pitty_pat/profile/player_profile.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/profile/progression.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _today = DateTime(2026, 10, 11);

MatchOutcome _match({
  AIDifficulty d = AIDifficulty.easy,
  int target = 5,
  bool won = true,
  int roundsWon = 5,
  int roundsLost = 2,
  bool daily = false,
}) =>
    MatchOutcome(
      difficulty: d,
      matchTarget: target,
      won: won,
      roundsWon: roundsWon,
      roundsLost: roundsLost,
      isDaily: daily,
    );

void main() {
  group('levels', () {
    test('level thresholds grow: 0, 100, 300, 600', () {
      expect(levelForXp(0), 1);
      expect(levelForXp(99), 1);
      expect(levelForXp(100), 2);
      expect(levelForXp(299), 2);
      expect(levelForXp(300), 3);
      expect(levelForXp(600), 4);
    });

    test('progress is the fraction of the current level', () {
      expect(levelProgress(0), 0);
      expect(levelProgress(50), 0.5);
      expect(levelProgress(200), 0.5);
    });
  });

  group('rewards', () {
    test('harder and longer matches pay more', () {
      final easy = matchReward(_match());
      final hard = matchReward(_match(d: AIDifficulty.hard));
      final long = matchReward(_match(target: 10, roundsWon: 10));
      expect(hard.coins, greaterThan(easy.coins));
      expect(hard.xp, greaterThan(easy.xp));
      expect(long.coins, easy.coins * 2);
    });

    test('a loss still earns something', () {
      final r = matchReward(_match(won: false, roundsWon: 2, roundsLost: 5));
      expect(r.coins, greaterThan(0));
      expect(r.xp, greaterThan(0));
    });

    test('daily streak bonus is capped', () {
      expect(dailyStreakBonus(1), 5);
      expect(dailyStreakBonus(30), 50);
    });
  });

  group('daily calendar', () {
    test('seed is the same for everyone on a date and differs by day', () {
      expect(dailySeed(_today), 20261011);
      expect(dailySeed(DateTime(2026, 10, 12)), isNot(dailySeed(_today)));
    });

    test('streak counts back from today, or yesterday if today is open', () {
      final done = {'2026-10-09', '2026-10-10'};
      expect(currentDailyStreak(done, _today), 2);
      expect(currentDailyStreak({...done, '2026-10-11'}, _today), 3);
      expect(currentDailyStreak({'2026-10-08'}, _today), 0);
    });

    test('streaks cross month boundaries', () {
      final done = {'2026-09-30', '2026-10-01'};
      expect(currentDailyStreak(done, DateTime(2026, 10, 1)), 2);
      expect(bestDailyStreak({...done, '2026-10-05', '2026-10-06', '2026-10-07'}), 3);
    });
  });

  group('applyMatch', () {
    test('a win updates stats, streak, coins, xp and first-win achievement', () {
      final (p, s) = applyMatch(const PlayerProfile(), _match(), _today);
      expect(p.statsFor(AIDifficulty.easy).matchesWon, 1);
      expect(p.currentWinStreak, 1);
      expect(s!.unlocked.map((a) => a.id), contains('first_win'));
      expect(p.coins, s.totalCoins);
      expect(p.xp, s.reward.xp);
      expect(p.achievements, contains('first_win'));
    });

    test('a loss resets the current streak but keeps the best', () {
      var p = const PlayerProfile(currentWinStreak: 4, bestWinStreak: 4);
      (p, _) = applyMatch(p, _match(won: false), _today);
      expect(p.currentWinStreak, 0);
      expect(p.bestWinStreak, 4);
    });

    test('a 3-0 win unlocks Clean Sweep; 5-1 does not', () {
      final (_, sweep) = applyMatch(const PlayerProfile(), _match(target: 3, roundsWon: 3, roundsLost: 0), _today);
      expect(sweep!.unlocked.map((a) => a.id), contains('sweep'));
      final (_, close) = applyMatch(const PlayerProfile(), _match(roundsLost: 1), _today);
      expect(close!.unlocked.map((a) => a.id), isNot(contains('sweep')));
    });

    test('daily challenge pays once per day and adds a streak bonus', () {
      final yesterday = const PlayerProfile(dailyCompleted: {'2026-10-10'});
      final (p, s) = applyMatch(yesterday, _match(daily: true), _today);
      expect(p.dailyCompleted, contains('2026-10-11'));
      expect(p.dailyWon, contains('2026-10-11'));
      expect(s!.streakBonus, 10); // 2-day streak
      expect(p.statsFor(AIDifficulty.easy).matchesPlayed, 0); // dailies don't touch stats

      final (again, none) = applyMatch(p, _match(daily: true), _today);
      expect(none, isNull);
      expect(again.coins, p.coins);
    });

    test('crossing a level threshold reports a level-up', () {
      final (_, s) = applyMatch(const PlayerProfile(xp: 90), _match(), _today);
      expect(s!.leveledUp, isTrue);
      expect(s.levelAfter, 2);
    });
  });

  group('applyPurchase', () {
    final geometric = cosmeticById(cardBackId(CardBackStyle.geometric));
    final royal = cosmeticById(cardBackId(CardBackStyle.royal));

    test('buys with enough coins and level', () {
      final (p, r) = applyPurchase(const PlayerProfile(coins: 200), geometric, _today);
      expect(r, PurchaseResult.purchased);
      expect(p.coins, 50);
      expect(p.owned, contains(geometric.id));
    });

    test('refuses when short on coins, level-locked, or already owned', () {
      expect(applyPurchase(const PlayerProfile(coins: 10), geometric, _today).$2, PurchaseResult.notEnoughCoins);
      expect(applyPurchase(const PlayerProfile(coins: 9999), royal, _today).$2, PurchaseResult.levelLocked);
      expect(applyPurchase(PlayerProfile(coins: 9999, owned: {geometric.id}), geometric, _today).$2,
          PurchaseResult.alreadyOwned);
    });
  });

  group('ProfileStore', () {
    test('starts with the free cosmetics and survives corrupt saves', () async {
      SharedPreferences.setMockInitialValues({'profile.v1': '{not json'});
      final store = ProfileStore(await SharedPreferences.getInstance(), now: () => _today);
      expect(store.profile.coins, 0);
      expect(store.owns(cardBackId(CardBackStyle.classic)), isTrue);
      expect(store.owns(feltId(FeltStyle.teal)), isTrue);
      expect(store.owns(cardBackId(CardBackStyle.geometric)), isFalse);
    });

    test('wrong-typed fields fall back without losing valid ones', () async {
      SharedPreferences.setMockInitialValues({
        'profile.v1': jsonEncode({'coins': 'lots', 'xp': 250, 'owned': ['back.midnight', 7]}),
      });
      final store = ProfileStore(await SharedPreferences.getInstance(), now: () => _today);
      expect(store.profile.coins, 0);
      expect(store.profile.xp, 250);
      expect(store.owns('back.midnight'), isTrue);
    });

    test('debug tools grant coins and XP and reset to starter items', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ProfileStore(await SharedPreferences.getInstance(), now: () => _today);
      store.debugGrantCoins(1000);
      store.debugGrantXp(500);
      expect(store.profile.coins, 1000);
      expect(store.level, 3);
      store.debugReset();
      expect(store.profile.coins, 0);
      expect(store.profile.xp, 0);
      expect(store.owns(cardBackId(CardBackStyle.classic)), isTrue);
    });

    test('records persist across reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = ProfileStore(prefs, now: () => _today);
      store.recordRound(AIDifficulty.hard, won: true);
      store.recordMatch(_match(d: AIDifficulty.hard));
      await Future<void>.delayed(Duration.zero);

      final reloaded = ProfileStore(prefs, now: () => _today);
      expect(reloaded.profile.statsFor(AIDifficulty.hard).roundsWon, 1);
      expect(reloaded.profile.statsFor(AIDifficulty.hard).matchesWon, 1);
      expect(reloaded.profile.achievements, containsAll(['first_win', 'sharp_win']));
    });
  });
}
