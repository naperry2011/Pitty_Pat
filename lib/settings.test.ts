import { describe, test, expect, beforeEach } from 'vitest';
import { loadSettings, saveSettings, DEFAULT_SETTINGS } from './settings';

beforeEach(() => localStorage.clear());

describe('settings', () => {
  test('returns defaults when nothing is stored', () => {
    expect(loadSettings()).toEqual(DEFAULT_SETTINGS);
  });
  test('round-trips saved settings', () => {
    saveSettings({ difficulty: 'hard', matchTarget: 10, soundMuted: true });
    expect(loadSettings()).toEqual({ difficulty: 'hard', matchTarget: 10, soundMuted: true });
  });
  test('ignores corrupt or invalid stored values', () => {
    localStorage.setItem('gameSettings', '{"difficulty":"impossible","matchTarget":7}');
    expect(loadSettings()).toEqual(DEFAULT_SETTINGS);
  });
});
