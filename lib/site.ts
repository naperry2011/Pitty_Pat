// Canonical site URL for metadata, sitemap, and robots.
// Set NEXT_PUBLIC_SITE_URL in the deployment environment; the fallback is the
// expected production domain so local builds produce sane absolute URLs.
export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL ?? 'https://pitty-pat.vercel.app';

// Public contact address shown on /privacy. Set NEXT_PUBLIC_CONTACT_EMAIL in the
// deployment environment; the contact line is hidden while it's unset.
export const CONTACT_EMAIL = process.env.NEXT_PUBLIC_CONTACT_EMAIL ?? '';
