import type { Metadata, Viewport } from 'next';
import { Inter, Fredoka } from 'next/font/google';
import './globals.css';
import { CardStyleProvider } from '@/contexts/CardStyleContext';
import { SITE_URL } from '@/lib/site';
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';

const inter = Inter({ subsets: ['latin'], variable: '--font-sans' });
const fredoka = Fredoka({ subsets: ['latin'], variable: '--font-display' });

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  viewportFit: 'cover',
  themeColor: '#FF6B6B',
};

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: 'Pitty Pat Card Game - Play Free Online | No Download Required',
  description: 'Play Pitty Pat online free! The classic card matching game with no ads or downloads. Challenge the computer in this fast-paced, easy-to-learn card game.',
  keywords: 'pitty pat, card game, online game, free game, play pitty pat online, pitty pat rules, card matching game',
  authors: [{ name: 'Pitty Pat Games' }],
  manifest: '/manifest.json',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'black-translucent',
    title: 'Pitty Pat',
  },
  openGraph: {
    title: 'Pitty Pat Card Game - Play Free Online',
    description: 'The only place to play Pitty Pat online! Fast, free, and fun card matching game.',
    type: 'website',
    locale: 'en_US',
    siteName: 'Pitty Pat Card Game',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }]
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Pitty Pat Card Game - Play Free Online',
    description: 'The classic card matching game is now online! Play free with no downloads.',
  },
  robots: 'index, follow'
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link rel="apple-touch-icon" href="/icon-192.png" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
        <meta name="mobile-web-app-capable" content="yes" />
      </head>
      <body className={`${inter.variable} ${fredoka.variable} font-sans`}>
        <CardStyleProvider>
          {children}
        </CardStyleProvider>
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
