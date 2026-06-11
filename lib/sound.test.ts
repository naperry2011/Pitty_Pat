// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { playSound, setMuted, isMuted, _setAudioFactoryForTests } from './sound';
import { loadSettings } from './settings';

interface FakeAudio {
  src: string;
  volume: number;
  currentTime: number;
  play: ReturnType<typeof vi.fn>;
}

function makeFactory() {
  const created: FakeAudio[] = [];
  const factory = vi.fn((src: string) => {
    const el: FakeAudio = {
      src,
      volume: 1,
      currentTime: 0,
      play: vi.fn(() => Promise.resolve())
    };
    created.push(el);
    return el as unknown as HTMLAudioElement;
  });
  return { factory, created };
}

beforeEach(() => {
  localStorage.clear();
});

describe('playSound', () => {
  it('creates and plays audio via the injected factory when unmuted', () => {
    const { factory, created } = makeFactory();
    _setAudioFactoryForTests(factory);
    setMuted(false);

    playSound('slide');

    expect(factory).toHaveBeenCalledTimes(1);
    expect(factory.mock.calls[0][0]).toContain('slide');
    expect(created[0].play).toHaveBeenCalledTimes(1);
  });

  it('reuses the pooled element per name and resets currentTime', () => {
    const { factory, created } = makeFactory();
    _setAudioFactoryForTests(factory);
    setMuted(false);

    playSound('match');
    created[0].currentTime = 0.3; // simulate partial playback
    playSound('match');

    expect(factory).toHaveBeenCalledTimes(1);
    expect(created[0].play).toHaveBeenCalledTimes(2);
    expect(created[0].currentTime).toBe(0);
  });

  it('is a no-op (factory not called) when muted', () => {
    const { factory } = makeFactory();
    _setAudioFactoryForTests(factory);
    setMuted(true);

    playSound('slide');

    expect(factory).not.toHaveBeenCalled();
  });
});

describe('setMuted', () => {
  it('persists soundMuted=true via settings and reports it', () => {
    const { factory } = makeFactory();
    _setAudioFactoryForTests(factory);

    setMuted(true);

    expect(isMuted()).toBe(true);
    expect(loadSettings().soundMuted).toBe(true);

    setMuted(false);
    expect(loadSettings().soundMuted).toBe(false);
  });

  it('initializes mute state from persisted settings', () => {
    const { factory } = makeFactory();
    localStorage.setItem(
      'gameSettings',
      JSON.stringify({ difficulty: 'easy', matchTarget: 5, soundMuted: true })
    );
    _setAudioFactoryForTests(factory); // resets cached state

    expect(isMuted()).toBe(true);
    playSound('slide');
    expect(factory).not.toHaveBeenCalled();
  });
});
