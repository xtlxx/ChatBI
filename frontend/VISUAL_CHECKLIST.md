# Visual Walkthrough Checklist

This checklist is used to verify the UI against `gemini.google.com/app`.

## 1. Visual Consistency
- [ ] **Color Palette**: 
  - Primary Blue (#0B57D0) is used for active states and primary buttons.
  - Background is #FFFFFF (Light) / #131314 (Dark).
  - Surface colors (Sidebar, Cards) match Gemini's muted tones.
- [ ] **Typography**:
  - Font family is "Google Sans".
  - Headings use correct weights (Medium 500).
  - Font sizes scale correctly on mobile.
- [ ] **Layout & Spacing**:
  - 8pt grid system is respected (spacings are multiples of 8px).
  - Sidebar width and collapse behavior match.
  - Chat container max-width limits line length for readability.
- [ ] **Shadows & Depth**:
  - Cards have subtle shadows.
  - Floating elements (Send button, Modals) have appropriate elevation.

## 2. Interactions & Animations
- [ ] **Buttons**:
  - Hover states have a slight background darken/lighten.
  - Click effect (Ripple or Scale) is present.
  - Transition duration is ~200ms.
- [ ] **Sidebar**:
  - Collapses/Expands smoothly.
  - Mobile drawer works as expected.
- [ ] **Chat**:
  - Streaming text appears smoothly.
  - "Thinking" state uses the sparkle animation.
  - Input area focus ring matches Gemini's style.

## 3. Components
- [ ] **Top Bar**:
  - Minimalist design.
  - Model selector is present.
- [ ] **Welcome Screen**:
  - Gradient greeting text.
  - Suggestion cards grid (4 items).
- [ ] **Message Bubbles**:
  - User: Rounded-xl, gray background.
  - AI: No background, Sparkle icon.
- [ ] **Input Area**:
  - Rounded-full container.
  - Icons (Plus, Image, Mic) in correct positions.

## 4. Performance
- [ ] First Contentful Paint (FCP) < 1.5s.
- [ ] Layout Shift (CLS) < 0.1.
- [ ] Accessibility (ARIA labels present on all buttons).

## 5. Cross-Browser
- [ ] Chrome (Latest)
- [ ] Safari (Latest)
- [ ] Firefox (Latest)
- [ ] Edge (Latest)
- [ ] Mobile WebKit (iOS)
