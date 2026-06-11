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
  test('returns defaults when stored value is not JSON', () => {
    localStorage.setItem('gameSettings', 'not json');
    expect(loadSettings()).toEqual(DEFAULT_SETTINGS);
  });
  test('falls back to default soundMuted when stored value has wrong type', () => {
    localStorage.setItem('gameSettings', '{"difficulty":"hard","matchTarget":3,"soundMuted":"yes"}');
    expect(loadSettings()).toEqual({ difficulty: 'hard', matchTarget: 3, soundMuted: false });
  });
});
