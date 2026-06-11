import { loadSettings, saveSettings } from './settings';

export type SoundName =
  | 'slide'
  | 'flip'
  | 'shuffle'
  | 'match'
  | 'round-win'
  | 'match-win';

// Sounds that accompany a physical card action get a small haptic tick too.
const HAPTIC_SOUNDS: ReadonlySet<SoundName> = new Set(['slide', 'match']);

const VOLUME = 0.5;

type AudioFactory = (src: string) => HTMLAudioElement;

const defaultFactory: AudioFactory = (src) => new Audio(src);

let factory: AudioFactory = defaultFactory;
// Lazy pool: one element per sound, created on first play and reused.
const pool = new Map<SoundName, HTMLAudioElement>();
// null = not yet read from persisted settings (resolved lazily, SSR-safe).
let muted: boolean | null = null;

function resolveMuted(): boolean {
  if (muted === null) {
    muted = loadSettings().soundMuted;
  }
  return muted;
}

export function isMuted(): boolean {
  if (typeof window === 'undefined') return true;
  return resolveMuted();
}

export function setMuted(value: boolean): void {
  muted = value;
  if (typeof window === 'undefined') return;
  saveSettings({ ...loadSettings(), soundMuted: value });
}

export function playSound(name: SoundName): void {
  if (typeof window === 'undefined') return; // SSR no-op
  if (resolveMuted()) return;

  try {
    let audio = pool.get(name);
    if (!audio) {
      audio = factory(`/sounds/${name}.ogg`);
      audio.volume = VOLUME;
      pool.set(name, audio);
    }
    audio.currentTime = 0;
    // play() returns a promise that rejects under autoplay policies; swallow it.
    void audio.play()?.catch?.(() => {});
  } catch {
    /* audio is best-effort; never break the game over it */
  }

  if (HAPTIC_SOUNDS.has(name) && typeof navigator !== 'undefined') {
    try {
      navigator.vibrate?.(15);
    } catch {
      /* ignore - haptics unsupported */
    }
  }
}

// Test seam: swap the Audio constructor and reset cached state.
export function _setAudioFactoryForTests(f: AudioFactory): void {
  factory = f;
  pool.clear();
  muted = null;
}
