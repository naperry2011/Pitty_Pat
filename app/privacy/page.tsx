import type { Metadata } from 'next';
import Link from 'next/link';
import { CONTACT_EMAIL } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Privacy Policy | Pitty Pat',
  description: 'How the Pitty Pat app and website handle your information.',
  robots: { index: true, follow: true },
};

const EFFECTIVE_DATE = 'October 11, 2026';

export default function Privacy() {
  return (
    <div className="min-h-screen bg-cream text-ink">
      <div className="container mx-auto px-4 py-8 max-w-3xl">
        <Link href="/" className="inline-block mb-4 text-coral-deep hover:text-coral transition-colors font-medium">
          ← Back to Game
        </Link>

        <h1 className="font-display text-4xl font-bold mb-2">Privacy Policy</h1>
        <p className="text-ink/60 mb-8">Effective {EFFECTIVE_DATE}</p>

        <div className="space-y-6">
          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-3 text-coral-deep">The short version</h2>
            <ul className="list-disc list-inside space-y-2 text-ink/80">
              <li>The Pitty Pat app has no accounts, no ads and no in-app purchases.</li>
              <li>Your progress (coins, levels, stats, daily challenge history and settings) is stored only on your device.</li>
              <li>We do not collect, sell or share personal information from the app.</li>
            </ul>
          </section>

          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-3 text-coral-deep">The Pitty Pat app (Android and iOS)</h2>
            <p className="text-ink/80 mb-3">
              The game runs entirely on your device. Game progress and preferences are saved in the app&apos;s local
              storage so they persist between sessions. This data never leaves your device and is removed if you
              uninstall the app or clear its data.
            </p>
            <p className="text-ink/80">
              If a future version adds optional features that involve a third-party service (for example, signing in
              to Google Play Games for leaderboards and achievements), those features will be optional, and we will
              update this policy before they are released to describe what is shared and with whom.
            </p>
          </section>

          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-3 text-coral-deep">This website</h2>
            <p className="text-ink/80">
              The website uses Vercel Web Analytics and Vercel Speed Insights to count visits and measure page
              performance. The browser game on this site saves your settings and card style in your browser&apos;s
              local storage, which stays on your device.
            </p>
          </section>

          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-3 text-coral-deep">Children</h2>
            <p className="text-ink/80">
              Pitty Pat is intended for players aged 13 and older and is not directed at children under 13. We do not
              knowingly collect personal information from anyone, including children.
            </p>
          </section>

          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-3 text-coral-deep">Changes and contact</h2>
            <p className="text-ink/80">
              If this policy changes, we will update the effective date above.
              {CONTACT_EMAIL && (
                <>
                  {' '}Questions? Email{' '}
                  <a className="text-coral-deep underline" href={`mailto:${CONTACT_EMAIL}`}>
                    {CONTACT_EMAIL}
                  </a>
                  .
                </>
              )}
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}
