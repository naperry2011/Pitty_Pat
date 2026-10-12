import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/cards/card_back.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsStore> _store(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsStore(await SharedPreferences.getInstance());
}

void main() {
  test('defaults when nothing is stored', () async {
    final s = (await _store({})).settings;
    expect(s.difficulty, AIDifficulty.easy);
    expect(s.matchTarget, 5);
    expect(s.soundMuted, isFalse);
    expect(s.cardBack, CardBackStyle.classic);
  });

  test('restores valid stored values', () async {
    final s = (await _store({
      'difficulty': 'hard',
      'matchTarget': 10,
      'soundMuted': true,
      'cardBack': 'gradient',
    }))
        .settings;
    expect(s.difficulty, AIDifficulty.hard);
    expect(s.matchTarget, 10);
    expect(s.soundMuted, isTrue);
    expect(s.cardBack, CardBackStyle.gradient);
  });

  test('invalid stored values fall back to defaults', () async {
    final s = (await _store({
      'difficulty': 'impossible',
      'matchTarget': 7,
      'cardBack': 'neon',
    }))
        .settings;
    expect(s.difficulty, AIDifficulty.easy);
    expect(s.matchTarget, 5);
    expect(s.cardBack, CardBackStyle.classic);
  });

  test('update persists and notifies', () async {
    final store = await _store({});
    var notified = 0;
    store.addListener(() => notified++);
    await store.update(store.settings.copyWith(difficulty: AIDifficulty.medium, matchTarget: 3));
    expect(notified, 1);

    final reloaded = SettingsStore(await SharedPreferences.getInstance()).settings;
    expect(reloaded.difficulty, AIDifficulty.medium);
    expect(reloaded.matchTarget, 3);
  });
}
