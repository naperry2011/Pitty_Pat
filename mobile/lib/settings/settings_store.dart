import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cards/card_back.dart';
import '../cosmetics/catalog.dart';
import '../game/ai_player.dart';

// Port of lib/settings.ts plus the equipped cosmetics (card back, felt, celebration).
// Ownership lives in the player profile; main.dart drops anything equipped but not owned.
const matchTargets = [3, 5, 10];
const opponentCounts = [1, 2, 3];
const passPlayerCounts = [2, 3, 4];
const defaultPassNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];
const maxPassNameLength = 12;

/// Seat names for a pass-and-play table: trimmed, capped, never blank, never repeated
/// (the "pass to" screen must be unambiguous).
List<String> resolvePassNames(List<String> raw, int count) {
  final out = <String>[];
  for (var i = 0; i < count; i++) {
    var name = i < raw.length ? raw[i].trim() : '';
    if (name.length > maxPassNameLength) name = name.substring(0, maxPassNameLength).trim();
    if (name.isEmpty) name = defaultPassNames[i];
    var unique = name;
    for (var n = 2; out.contains(unique); n++) {
      unique = '$name $n';
    }
    out.add(unique);
  }
  return out;
}

class GameSettings {
  const GameSettings({
    this.difficulty = AIDifficulty.easy,
    this.matchTarget = 5,
    this.soundMuted = false,
    this.cardBack = CardBackStyle.classic,
    this.felt = FeltStyle.teal,
    this.celebration = CelebrationStyle.confetti,
    this.tutorialDone = false,
    this.opponents = 1,
    this.chatter = true,
    this.passPlayers = 2,
    this.passNames = defaultPassNames,
  });

  final AIDifficulty difficulty;
  final int matchTarget;
  final bool soundMuted;
  final CardBackStyle cardBack;
  final FeltStyle felt;
  final CelebrationStyle celebration;
  final bool tutorialDone;
  final int opponents; // computer opponents at the table, 1-3
  final bool chatter; // opponents' speech bubbles
  final int passPlayers; // pass-and-play table size, 2-4
  final List<String> passNames; // remembered pass-and-play names, one per seat

  GameSettings copyWith({
    AIDifficulty? difficulty,
    int? matchTarget,
    bool? soundMuted,
    CardBackStyle? cardBack,
    FeltStyle? felt,
    CelebrationStyle? celebration,
    bool? tutorialDone,
    int? opponents,
    bool? chatter,
    int? passPlayers,
    List<String>? passNames,
  }) =>
      GameSettings(
        difficulty: difficulty ?? this.difficulty,
        matchTarget: matchTarget ?? this.matchTarget,
        soundMuted: soundMuted ?? this.soundMuted,
        cardBack: cardBack ?? this.cardBack,
        felt: felt ?? this.felt,
        celebration: celebration ?? this.celebration,
        tutorialDone: tutorialDone ?? this.tutorialDone,
        opponents: opponents ?? this.opponents,
        chatter: chatter ?? this.chatter,
        passPlayers: passPlayers ?? this.passPlayers,
        passNames: passNames ?? this.passNames,
      );
}

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._prefs) : _settings = _load(_prefs);

  static const _kDifficulty = 'difficulty';
  static const _kMatchTarget = 'matchTarget';
  static const _kSoundMuted = 'soundMuted';
  static const _kCardBack = 'cardBack';
  static const _kFelt = 'felt';
  static const _kCelebration = 'celebration';
  static const _kTutorialDone = 'tutorialDone';
  static const _kOpponents = 'opponents';
  static const _kChatter = 'chatter';
  static const _kPassPlayers = 'passPlayers';
  static const _kPassNames = 'passNames';

  final SharedPreferences _prefs;
  GameSettings _settings;

  GameSettings get settings => _settings;

  // Every stored field is validated; anything unknown falls back to the default.
  static GameSettings _load(SharedPreferences prefs) {
    const d = GameSettings();
    T byName<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    final target = prefs.getInt(_kMatchTarget);

    return GameSettings(
      difficulty: byName(AIDifficulty.values, prefs.getString(_kDifficulty), d.difficulty),
      matchTarget: matchTargets.contains(target) ? target! : d.matchTarget,
      soundMuted: prefs.getBool(_kSoundMuted) ?? d.soundMuted,
      cardBack: byName(CardBackStyle.values, prefs.getString(_kCardBack), d.cardBack),
      felt: byName(FeltStyle.values, prefs.getString(_kFelt), d.felt),
      celebration: byName(CelebrationStyle.values, prefs.getString(_kCelebration), d.celebration),
      tutorialDone: prefs.getBool(_kTutorialDone) ?? d.tutorialDone,
      opponents: opponentCounts.contains(prefs.getInt(_kOpponents)) ? prefs.getInt(_kOpponents)! : d.opponents,
      chatter: prefs.getBool(_kChatter) ?? d.chatter,
      passPlayers: passPlayerCounts.contains(prefs.getInt(_kPassPlayers)) ? prefs.getInt(_kPassPlayers)! : d.passPlayers,
      passNames: _validNames(prefs.getStringList(_kPassNames)),
    );
  }

  Future<void> update(GameSettings next) async {
    _settings = next;
    notifyListeners();
    // Persistence failure must not block play.
    try {
      await Future.wait([
        _prefs.setString(_kDifficulty, next.difficulty.name),
        _prefs.setInt(_kMatchTarget, next.matchTarget),
        _prefs.setBool(_kSoundMuted, next.soundMuted),
        _prefs.setString(_kCardBack, next.cardBack.name),
        _prefs.setString(_kFelt, next.felt.name),
        _prefs.setString(_kCelebration, next.celebration.name),
        _prefs.setBool(_kTutorialDone, next.tutorialDone),
        _prefs.setInt(_kOpponents, next.opponents),
        _prefs.setBool(_kChatter, next.chatter),
        _prefs.setInt(_kPassPlayers, next.passPlayers),
        _prefs.setStringList(_kPassNames, next.passNames),
      ]);
    } catch (_) {}
  }
}

class SettingsScope extends InheritedNotifier<SettingsStore> {
  const SettingsScope({super.key, required SettingsStore store, required super.child})
      : super(notifier: store);

  static SettingsStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}

List<String> _validNames(List<String>? stored) =>
    stored != null && stored.length == defaultPassNames.length ? resolvePassNames(stored, stored.length) : defaultPassNames;
