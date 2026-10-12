import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

// Port of lib/sound.ts. Presentation-only: the game never depends on these.
enum SoundCue {
  slide('slide'),
  flip('flip'),
  shuffle('shuffle'),
  match('match'),
  roundWin('round-win'),
  matchWin('match-win');

  const SoundCue(this.file);
  final String file;

  // Sounds that accompany a physical card action get a small haptic tick too.
  bool get hasHaptic => this == SoundCue.slide || this == SoundCue.match;
}

abstract interface class SoundPlayer {
  void play(SoundCue cue);
}

class SoundEffects implements SoundPlayer {
  SoundEffects._();
  static final SoundEffects instance = SoundEffects._();

  static const _volume = 0.5;

  // Game SFX mix with the player's music instead of pausing it: no audio focus
  // on Android; iOS "ambient" mixes and honors the silent switch.
  static final _context = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  // Lazy pool: one per sound, created on first play and reused.
  final _pools = <SoundCue, Future<AudioPool>>{};

  @override
  void play(SoundCue cue) {
    _playAudio(cue);
    if (cue.hasHaptic) {
      HapticFeedback.lightImpact().catchError((_) {});
    }
  }

  Future<void> _playAudio(SoundCue cue) async {
    // Audio is best-effort; never break the game over it.
    try {
      final pool = await (_pools[cue] ??= AudioPool.create(
        source: AssetSource('sounds/${cue.file}.ogg'),
        maxPlayers: 3,
        audioContext: _context,
      ));
      await pool.start(volume: _volume);
    } catch (_) {
      _pools.remove(cue);
    }
  }
}

// The player screens use by default; tests swap in a recorder (like the web's
// _setAudioFactoryForTests seam).
SoundPlayer defaultSoundPlayer = SoundEffects.instance;

class MutedSoundPlayer implements SoundPlayer {
  const MutedSoundPlayer();

  @override
  void play(SoundCue cue) {}
}
