# Design System — Blue & Grey (Swastha Aur Abhiman)

This folder contains the global design system used across the app. Conventions below must be followed to maintain an official, trustworthy, and accessible look.

Palette (DO NOT CHANGE):
- Primary:   `#395A7F` (Deep Slate Blue)
- Secondary: `#6E9FC1` (Steel Blue)
- Accent:    `#A3CAE9` (Light Sky Blue)
- Background:`#E9ECEE` (Off-White Grey)
- Border:    `#ACACAC` (Medium Grey)

Global rules:
- AppBar / Header: `backgroundColor: primary` with white text.
- Scaffold background: `background` (never `#FFFFFF` for full page backgrounds).
- CTA Buttons (Primary): solid `primary` background with white text, rounded corners.
- Secondary Buttons/Links: use `secondary` color for text or outline.
- Cards: `white` surface with `border` as thin divider.
- Active/Selected: `accent` as background highlight.
- Body text: use dark `#2C3E50` for high contrast. Do NOT use `border` grey for body text.

Accessibility:
- Ensure font sizes and weight provide high contrast and sufficient readable size.
- Use semantic widgets (Buttons, ListTile) so themes and a11y features apply automatically.

Examples:
- Use `ElevatedButton` for primary CTAs.
- Use `TextButton` / `OutlinedButton` for secondary actions.
- For custom cards prefer `AppCard` helper from `app_widgets.dart` (keeps consistent padding & border).
