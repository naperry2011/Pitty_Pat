'use client';

import { useState, useEffect } from 'react';
import GameBoard from '@/components/game/GameBoard';
import SetupScreen from '@/components/game/SetupScreen';
import { GameSettings, DEFAULT_SETTINGS, loadSettings } from '@/lib/settings';

export default function PlayPage() {
  const [settings, setSettings] = useState<GameSettings | null>(null);
  const [initialSettings, setInitialSettings] = useState<GameSettings>(DEFAULT_SETTINGS);
  const [restored, setRestored] = useState(false);

  // Hydration-safe restore: prerender shows defaults, stored settings apply after mount.
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setInitialSettings(loadSettings());
    setRestored(true);
  }, []);

  return (
    <main className="min-h-screen">
      {settings === null ? (
        // Key remounts SetupScreen once stored settings load, so its local
        // selection state picks up the restored values instead of defaults.
        <SetupScreen key={String(restored)} initial={initialSettings} onStart={setSettings} />
      ) : (
        <GameBoard
          settings={settings}
          onChangeSettings={() => {
            // Re-read persisted settings (e.g. mute toggled in-game) so
            // SetupScreen doesn't save stale values back over them.
            setInitialSettings(loadSettings());
            setSettings(null);
          }}
        />
      )}
    </main>
  );
}
