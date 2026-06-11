'use client';

import React, { useState } from 'react';
import { GameSettings, saveSettings } from '@/lib/settings';
import { AIDifficulty } from '@/lib/ai-player';
import clsx from 'clsx';

interface SetupScreenProps {
  initial: GameSettings;
  onStart: (settings: GameSettings) => void;
}

const DIFFICULTY_OPTIONS: { value: AIDifficulty; label: string; description: string }[] = [
  { value: 'easy', label: 'Chill', description: 'Relaxed opponent' },
  { value: 'medium', label: 'Clever', description: 'Thinks it through' },
  { value: 'hard', label: 'Sharp', description: 'Plays to win' }
];

const TARGET_OPTIONS: GameSettings['matchTarget'][] = [3, 5, 10];

export default function SetupScreen({ initial, onStart }: SetupScreenProps) {
  const [difficulty, setDifficulty] = useState<AIDifficulty>(initial.difficulty);
  const [matchTarget, setMatchTarget] = useState<GameSettings['matchTarget']>(initial.matchTarget);

  const handlePlay = () => {
    const selection: GameSettings = { difficulty, matchTarget, soundMuted: initial.soundMuted };
    saveSettings(selection);
    onStart(selection);
  };

  return (
    <div className="min-h-screen playful-bg flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md flex flex-col gap-6">
        <h1 className="text-3xl sm:text-4xl font-black text-center text-transparent bg-clip-text bg-gradient-to-r from-coral to-soft-purple">
          Game Setup 🎴
        </h1>

        {/* Difficulty picker */}
        <fieldset className="bg-white/70 backdrop-blur-sm rounded-2xl p-4 shadow-soft">
          <legend className="sr-only">Computer difficulty</legend>
          <div className="text-gray-700 font-bold text-sm mb-3">How tough is the computer?</div>
          <div className="grid grid-cols-3 gap-2" role="group" aria-label="Difficulty">
            {DIFFICULTY_OPTIONS.map(option => (
              <button
                key={option.value}
                type="button"
                aria-pressed={difficulty === option.value}
                onClick={() => setDifficulty(option.value)}
                className={clsx(
                  'rounded-xl px-2 py-3 text-center transition-all touch-target',
                  difficulty === option.value
                    ? 'bg-gradient-to-r from-coral to-suit-hearts text-white shadow-playful scale-105'
                    : 'bg-white/80 text-gray-700 shadow-soft active:scale-95'
                )}
              >
                <div className="font-bold text-base">{option.label}</div>
                <div className={clsx(
                  'text-xs mt-0.5',
                  difficulty === option.value ? 'text-white/90' : 'text-gray-500'
                )}>
                  {option.description}
                </div>
              </button>
            ))}
          </div>
        </fieldset>

        {/* Match length picker */}
        <fieldset className="bg-white/70 backdrop-blur-sm rounded-2xl p-4 shadow-soft">
          <legend className="sr-only">Match length</legend>
          <div className="text-gray-700 font-bold text-sm mb-3">How long is the match?</div>
          <div className="grid grid-cols-3 gap-2" role="group" aria-label="Match length">
            {TARGET_OPTIONS.map(target => (
              <button
                key={target}
                type="button"
                aria-pressed={matchTarget === target}
                onClick={() => setMatchTarget(target)}
                className={clsx(
                  'rounded-xl px-2 py-3 font-bold text-base transition-all touch-target',
                  matchTarget === target
                    ? 'bg-gradient-to-r from-coral to-suit-hearts text-white shadow-playful scale-105'
                    : 'bg-white/80 text-gray-700 shadow-soft active:scale-95'
                )}
              >
                First to {target}
              </button>
            ))}
          </div>
        </fieldset>

        {/* Play button */}
        <button
          type="button"
          onClick={handlePlay}
          className="btn-playful text-xl touch-target self-center px-10"
        >
          Play! 🎮
        </button>
      </div>
    </div>
  );
}
