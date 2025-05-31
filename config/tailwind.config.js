const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
    content: [
        './public/*.html',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
        './app/views/**/*.{erb,haml,html,slim}',
        './app/lib/form_builders/**/*.rb',
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['Nunito', 'Inter var', ...defaultTheme.fontFamily.sans],
                serif: ['Instrument Serif', ...defaultTheme.fontFamily.serif],
                mono: ['Space Mono', ...defaultTheme.fontFamily.mono],
            },
        },
    },
    plugins: [
        // require('@tailwindcss/forms'),
        require('@tailwindcss/aspect-ratio'),
        require('@tailwindcss/typography'),
        require('@tailwindcss/container-queries'),
    ]
}
