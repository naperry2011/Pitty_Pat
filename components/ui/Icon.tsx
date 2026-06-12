import React from 'react';

export type IconName =
  | 'home'
  | 'settings'
  | 'sound-on'
  | 'sound-off'
  | 'trophy'
  | 'cards'
  | 'arrow-down';

interface IconProps {
  name: IconName;
  size?: number;
  className?: string;
  'aria-label'?: string;
}

const PATHS: Record<IconName, React.ReactNode> = {
  home: (
    <>
      <path d="M3 11.5 12 4l9 7.5" />
      <path d="M5.5 10.5V20h13v-9.5" />
      <path d="M10 20v-5.5h4V20" />
    </>
  ),
  settings: (
    <>
      <circle cx="12" cy="12" r="3.25" />
      <path d="M19.4 13.5a7.6 7.6 0 0 0 0-3l2-1.5-2-3.5-2.4 1a7.6 7.6 0 0 0-2.6-1.5L14 2.5h-4L9.6 5a7.6 7.6 0 0 0-2.6 1.5l-2.4-1-2 3.5 2 1.5a7.6 7.6 0 0 0 0 3l-2 1.5 2 3.5 2.4-1a7.6 7.6 0 0 0 2.6 1.5l.4 2.5h4l.4-2.5a7.6 7.6 0 0 0 2.6-1.5l2.4 1 2-3.5Z" />
    </>
  ),
  'sound-on': (
    <>
      <path d="M4 9.5v5h3.5L12 18.5v-13L7.5 9.5Z" />
      <path d="M15.5 9a4.5 4.5 0 0 1 0 6" />
      <path d="M18 6.5a8 8 0 0 1 0 11" />
    </>
  ),
  'sound-off': (
    <>
      <path d="M4 9.5v5h3.5L12 18.5v-13L7.5 9.5Z" />
      <path d="m16 9.5 5 5" />
      <path d="m21 9.5-5 5" />
    </>
  ),
  trophy: (
    <>
      <path d="M7 4h10v6a5 5 0 0 1-10 0Z" />
      <path d="M7 5.5H4a3 3 0 0 0 3 4.5" />
      <path d="M17 5.5h3a3 3 0 0 1-3 4.5" />
      <path d="M12 15v3.5" />
      <path d="M8.5 21h7" />
      <path d="M10 18.5h4V21h-4Z" />
    </>
  ),
  cards: (
    <>
      <rect x="3" y="6" width="10" height="14" rx="2" transform="rotate(-8 8 13)" />
      <rect x="11" y="4" width="10" height="14" rx="2" transform="rotate(8 16 11)" />
    </>
  ),
  'arrow-down': <path d="m6 9 6 6 6-6" />,
};

export default function Icon({ name, size = 20, className, 'aria-label': ariaLabel }: IconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden={ariaLabel ? undefined : true}
      aria-label={ariaLabel}
      role={ariaLabel ? 'img' : undefined}
    >
      {PATHS[name]}
    </svg>
  );
}
