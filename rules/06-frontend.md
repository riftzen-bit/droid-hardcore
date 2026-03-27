# Frontend Quality

## Design — Anti-Slop
Before writing frontend code, commit to a BOLD aesthetic:
- Purpose: What problem does this solve? Who uses it?
- Tone: brutally minimal, retro-futuristic, organic, luxury, editorial, brutalist, art deco, industrial — never "generic modern"
- Differentiation: What makes this UNFORGETTABLE?

### Always Do
- Distinctive, characterful fonts — pair display + body
- CSS variables for cohesive color themes
- Atmosphere: gradients, noise textures, geometric patterns, grain overlays
- Animations purposefully — orchestrated page load > scattered micro-interactions

### Never Do (AI Slop Blacklist)
- Inter, Roboto, Arial as primary font
- Purple/indigo gradients on white
- Generic 3-card icon grids, cookie-cutter heroes
- Unstyled Tailwind defaults (blue-500, gray-100)
- Any pattern that looks "AI generated"

## CSS — One Approach Per Project
Detect: Tailwind? CSS Modules? CSS-in-JS? Do not mix.

## Accessibility (WCAG 2.1 AA)
- Contrast: 4.5:1 normal, 3:1 large text
- Semantic HTML: `<button>` not `<div onClick>`
- Keyboard navigable, ARIA labels, alt text, focus indicators

## Responsive — Mobile First
- Base styles for mobile, min-width queries for larger
- Touch targets: minimum 44x44px
- No horizontal scrolling
