import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        // Kid-friendly color palette
        'sky-start': '#87CEEB',
        'sky-end': '#E6E6FA',
        'coral': '#FF6B6B',
        'sunny': '#FFE66D',
        'mint': '#4ECDC4',
        'soft-purple': '#DDA0DD',
        // Colorful suit colors
        'suit-hearts': '#FF6B6B',
        'suit-diamonds': '#FF9F43',
        'suit-clubs': '#4ECDC4',
        'suit-spades': '#5F7ADB',
      },
      animation: {
        'card-flip': 'flip 0.6s ease-in-out',
        'card-deal': 'deal 0.5s ease-out',
        'card-draw': 'draw 0.4s ease-out',
        'bounce-gentle': 'bounceGentle 0.6s ease-out',
        'bounce-win': 'bounceWin 0.5s ease-out infinite',
        'wiggle': 'wiggle 0.3s ease-in-out',
        'pop': 'pop 0.3s ease-out',
        'confetti': 'confetti 1s ease-out forwards',
        'float': 'float 3s ease-in-out infinite',
        'pulse-soft': 'pulseSoft 2s ease-in-out infinite',
      },
      keyframes: {
        flip: {
          '0%': { transform: 'rotateY(0deg)' },
          '100%': { transform: 'rotateY(180deg)' },
        },
        deal: {
          '0%': { transform: 'translateY(-100px) scale(0.8)', opacity: '0' },
          '100%': { transform: 'translateY(0) scale(1)', opacity: '1' },
        },
        draw: {
          '0%': { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(20px)' },
        },
        bounceGentle: {
          '0%': { transform: 'scale(1)' },
          '50%': { transform: 'scale(1.1)' },
          '100%': { transform: 'scale(1)' },
        },
        bounceWin: {
          '0%, 100%': { transform: 'translateY(0) scale(1)' },
          '50%': { transform: 'translateY(-10px) scale(1.05)' },
        },
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
        pop: {
          '0%': { transform: 'scale(0.95)', opacity: '0.8' },
          '50%': { transform: 'scale(1.05)' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
        confetti: {
          '0%': { transform: 'translateY(0) rotate(0deg)', opacity: '1' },
          '100%': { transform: 'translateY(100vh) rotate(720deg)', opacity: '0' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' },
        },
        pulseSoft: {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%': { opacity: '0.8', transform: 'scale(1.02)' },
        },
      },
      borderRadius: {
        '2xl': '1rem',
        '3xl': '1.5rem',
        '4xl': '2rem',
      },
      boxShadow: {
        'card': '0 4px 12px -2px rgba(0, 0, 0, 0.15), 0 2px 6px -2px rgba(0, 0, 0, 0.1)',
        'card-hover': '0 8px 20px -4px rgba(0, 0, 0, 0.2), 0 4px 10px -4px rgba(0, 0, 0, 0.1)',
        'card-selected': '0 0 0 4px rgba(255, 230, 109, 0.6), 0 8px 20px -4px rgba(0, 0, 0, 0.2)',
        'soft': '0 2px 8px rgba(0, 0, 0, 0.1)',
        'playful': '0 6px 20px -5px rgba(255, 107, 107, 0.4)',
      },
    },
  },
  plugins: [],
}

export default config
