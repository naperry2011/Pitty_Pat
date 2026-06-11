import { AIDifficulty } from './ai-player';

export interface GameSettings {
  difficulty: AIDifficulty;
  matchTarget: 3 | 5 | 10;
  soundMuted: boolean;
}

export const DEFAULT_SETTINGS: GameSettings = { difficulty: 'easy', matchTarget: 5, soundMuted: false };
const KEY = 'gameSettings';
const DIFFICULTIES = ['easy', 'medium', 'hard'];
const TARGETS = [3, 5, 10];

export function loadSettings(): GameSettings {
  if (typeof window === 'undefined') return DEFAULT_SETTINGS;
  try {
    const raw = JSON.parse(localStorage.getItem(KEY) ?? '');
    if (DIFFICULTIES.includes(raw.difficulty) && TARGETS.includes(raw.matchTarget)) {
      return { ...DEFAULT_SETTINGS, ...raw };
    }
  } catch { /* fall through to defaults */ }
  return DEFAULT_SETTINGS;
}

export function saveSettings(settings: GameSettings) {
  localStorage.setItem(KEY, JSON.stringify(settings));
}
