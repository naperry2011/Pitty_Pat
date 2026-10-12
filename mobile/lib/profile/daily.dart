// Daily challenge calendar math. Everyone gets the same deal on a given local
// date because the shuffle is seeded from that date.

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}

/// Deterministic seed for a date, e.g. 2026-10-11 -> 20261011.
int dailySeed(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Consecutive completed days ending today, or yesterday if today isn't done yet
/// (so the streak isn't shown as broken before the player has had a chance).
int currentDailyStreak(Set<String> completed, DateTime today) {
  var day = _day(today);
  if (!completed.contains(dateKey(day))) {
    day = DateTime(day.year, day.month, day.day - 1);
  }
  var streak = 0;
  while (completed.contains(dateKey(day))) {
    streak++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return streak;
}

int bestDailyStreak(Set<String> completed) {
  final days = completed.map(parseDateKey).toList()..sort();
  var best = 0;
  var run = 0;
  DateTime? prev;
  for (final d in days) {
    final consecutive =
        prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d;
    run = consecutive ? run + 1 : 1;
    if (run > best) best = run;
    prev = d;
  }
  return best;
}
