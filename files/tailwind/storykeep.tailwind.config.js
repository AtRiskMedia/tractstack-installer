/** @type {import('tailwindcss').Config} */
module.exports = {
  plugins: [
    require('@tailwindcss/forms'),
  ],
  content: [
    './src/pages/**/*.{js,jsx,tsx}',
    './src/components/**/*.{js,jsx,tsx}',
    './src/shopify-components/**/*.{js,jsx,tsx}',
    './src/custom/**/*.{js,jsx,tsx}',
    './src/templates/**/*.{js,jsx,tsx}',
  ],
  safelist: [
    {
      pattern:
        /^(w|min-w|h|min-h|max-w|max-h|basis|grow|col|auto-cols|justify-items|self|flex|shrink|grid-rows|auto-rows|justify-self|place-content|order|row|gap|content|place-items|grid-cols|grid-flow|justify|items|place-self)-/,
      variants: ['md','xl'],
    },
    {
      pattern: /^(rotate|-rotate|scale)-/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^(p|px|py|pt|pr|pb|pl|m|mx|my|mt|mr|mb|ml)-/,
      variants: ['md','xl'],
    },
    {
      pattern:
        /^text-(center|left|right|justify|start|end|xs|sm|base|lg|xl|2xl|3xl|4xl|5xl|6xl|7xl|8xl|9xl|rxs|rsm|rbase|rlg|rxl|r2xl|r3xl|r4xl|r5xl|r6xl|r7xl|r8xl|r9xl|ellipsis|clip|wrap|nowrap|balance|pretty)$/,
      variants: ['md','xl'],
    },
    {
      pattern: /^text-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern:
        /^bg-(bottom|center|left|left-bottom|left-top|right|right-bottom|right-top|top|repeat|no-repeat|repeat-x|repeat-y|repeat-round|repeat-space|auto|cover|contain)$/,
      variants: ['md','xl'],
    },
    {
      pattern: /^(bg|text)-my[a-z]*$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^(fill|stroke)-my[a-z]*$/,
      variants: ['md','xl'],
    },
    {
      pattern: /^bg-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern:
        /^decoration-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^shadow-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^shadow-(sm|md|lg|xl|2xl|inner|none)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern:
        /^decoration-([01248]|from-front|auto|dotted|double|dashed|wavy)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^outline-([01248]|none|dashed|dotted|double|offset-\d)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^outline-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^ring-(\d|inset)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^ring-offset-\d$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern:
        /^ring-offset-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^ring-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^border-(-[xylrtb])?(\d|[xylrtb]|([xylrtb]-\d))$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^border-(solid|dashed|dotted|double|hidden|none)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^border-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^stroke-\d$/,
      variants: ['md','xl'],
    },
    {
      pattern: /^underline-offset-(auto|[01248])$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern: /^leading-([3456789]|10|none|tight|snug|normal|relaxed|loose)$/,
      variants: ['md','xl'],
    },
    {
      pattern: /^stroke-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['md','xl'],
    },
    {
      pattern: /^fill-(inherit|current|transparent|black|white|[a-z]*-\d*)$/,
      variants: ['md','xl'],
    },
    {
      pattern:
        /^(ring|outline|border|underline|no-underline|overline|line-through|shadow)$/,
      variants: ['hover', 'focus','md','xl'],
    },
    {
      pattern:
        /^(sr-only|not-sr-only|transition|shrink|grow|rounded|truncate|italic|not-italic|uppercase|lowercase|capitalize|normal-case|static|fixed|absolute|relative|sticky|visible|invisible|collapse|isolate)$/,
      variants: ['md','xl'],
    },
    {
      pattern:
        /^(block|inline-block|inline|flex|inline-flex|table|inline-table|table-caption|table-cell|table-column|table-column-group|table-footer-group|table-header-group|table-row-group|table-row|flow-root|grid|inline-grid|contents|list-item|hidden)$/,
      variants: ['md','xl'],
    },
    {
      pattern:
        /^(animate|transition|duration|ease|delay|rounded|gap|pointer-events|font|leading|whitespace|break|tracking|list|indent|line-clamp|align|opacity|aspect|object|float|object|columns|clear|overflow|box|isolation|overscroll|z|inset|start|end|top|right|bottom|left)-/,
      variants: ['md','xl'],
    },
  ],
  theme: {
    screens: {
      xs: "0px",
      md: "801px",
      xl: "1367px",
    },
    extend: {
      animation: {
        fadeOut: 'fadeOut 1s forwards',
        fadeIn: 'fadeIn 1s ease-in',
        fadeInUp: 'fadeInUp 1s ease-in',
        fadeInRight: 'fadeInRight 1s ease-in',
        fadeInLeft: 'fadeInLeft 1s ease-in',
        bounceIn: 'bounce 1s ease-in-out 4.5',
        wig: 'wiggle 1s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '.25' },
          '100%': { opacity: '1' },
        },
        fadeInUp: {
          '0%': { transform: 'translate3d(0, 10px, 0)', opacity: '.25' },
          '100%': { transform: 'translate3d(0, 0, 0)', opacity: '1' },
        },
        fadeInRight: {
          '0%': { transform: 'translate3d(10px,0, 0)', opacity: '.25' },
          '100%': { transform: 'translate3d(0, 0, 0)', opacity: '1' },
        },
        fadeInLeft: {
          '0%': { transform: 'translate3d(-10px,0, 0)', opacity: '.25' },
          '100%': { transform: 'translate3d(0, 0, 0)', opacity: '1' },
        },
      },
      lineHeight: {
        12: '3rem',
        14: '3.5rem',
        16: '4rem',
        20: '5rem',
      },
      spacing: {
        r1: 'calc(var(--scale) * .25rem)',
        r2: 'calc(var(--scale) * .5rem)',
        r3: 'calc(var(--scale) * .75rem)',
        r4: 'calc(var(--scale) * 1rem)',
        r5: 'calc(var(--scale) * 1.25rem)',
        r6: 'calc(var(--scale) * 1.5rem)',
        r7: 'calc(var(--scale) * 1.75rem)',
        r8: 'calc(var(--scale) * 2rem)',
        r9: 'calc(var(--scale) * 2.25rem)',
        r10: 'calc(var(--scale) * 2.5rem)',
        r11: 'calc(var(--scale) * 2.75rem)',
        r12: 'calc(var(--scale) * 3rem)',
        r14: 'calc(var(--scale) * 3.5rem)',
        r16: 'calc(var(--scale) * 4rem)',
        r20: 'calc(var(--scale) * 5rem)',
      },
      fontFamily: {
        action: [
          'var(--font-action)',
          'Inter',
          'Georgia',
          'Times New Roman',
          'Times',
          'serif'
        ],
        main: [
          'var(--font-main)',
          'Inter',
          'Arial',
          'Helvetica Neue',
          'Helvetica',
          'sans-serif'
        ], 
      },
      fontSize: {
        rxs: 'calc(var(--scale) * 0.75rem)',
        rsm: 'calc(var(--scale) * 0.875rem)',
        rbase: 'calc(var(--scale) * 1rem)',
        rlg: 'calc(var(--scale) * 1.125rem)',
        rxl: 'calc(var(--scale) * 1.25rem)',
        r2xl: 'calc(var(--scale) * 1.5rem)',
        r3xl: 'calc(var(--scale) * 1.875rem)',
        r4xl: 'calc(var(--scale) * 2.5rem)',
        r5xl: 'calc(var(--scale) * 3rem)',
        r6xl: 'calc(var(--scale) * 3.75rem)',
        r7xl: 'calc(var(--scale) * 4.5rem)',
        r8xl: 'calc(var(--scale) * 6rem)',
        r9xl: 'calc(var(--scale) * 8rem)',
      },
      zIndex: {
        1: '101',
        2: '102',
        3: '103',
        4: '104',
        5: '105',
        6: '106',
        7: '107',
        8: '108',
        9: '109',
        10: '110',
        20: '210',
        30: '310',
        40: '410',
        50: '510',
        70: '700',
        90: '900',
        99: '999',
        101: '1001',
        102: '1002',
        103: '1003',
        104: '1004',
        105: '1005',
        999: '9999',
      },
      colors: {
        mywhite: '#fcfcfc',
        myoffwhite: '#e3e3e3',
        myallwhite: '#ffffff',
        mylightgrey: '#a7b1b7',
        myblue: '#293f58',
        mygreen: '#c8df8c',
        myorange: '#f58333',
        mydarkgrey: '#393d34',
        myblack: '#10120d',
        'brand-1': 'var(--brand-1)',
        'brand-2': 'var(--brand-2)',
        'brand-3': 'var(--brand-3)',
        'brand-4': 'var(--brand-4)',
        'brand-5': 'var(--brand-5)',
        'brand-6': 'var(--brand-6)',
        'brand-7': 'var(--brand-7)',
        'brand-8': 'var(--brand-8)',
      },
    },
  },
  plugins: [require('@tailwindcss/forms')],
}
