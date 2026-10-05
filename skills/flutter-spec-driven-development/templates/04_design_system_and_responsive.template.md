# 04 - Design System & Responsive Layout Specification

## 1. Design Philosophy & Material 3
- Design Language: **Material 3 (M3)** with custom brand tokens.
- Light and Dark mode support is mandatory across all views.
- High aesthetic standard: smooth animations, curated typography, clear contrast ratios.

---

## 2. Color Palette & Brand Tokens

| Token Name | Light Value | Dark Value | Purpose |
|---|---|---|---|
| `colorSchemeSeed` | `[e.g. #3F51B5 (Indigo)]` | `[e.g. #3F51B5 (Indigo)]` | M3 dynamic seed generating palette |
| `primary` | `[Hex Code]` | `[Hex Code]` | Primary interactive controls, FAB, active tabs |
| `surface` | `[Hex Code]` | `[Hex Code]` | Card backgrounds, sheet surfaces |
| `background` | `[Hex Code]` | `[Hex Code]` | Screen background |
| `error` | `[Hex Code]` | `[Hex Code]` | Error alerts, invalid validation states |

---

## 3. Typography Hierarchy
Font Family: **[e.g. Inter / Roboto / System Font]**

| Style | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 57px | Regular | 64px | Hero statistics / landing titles |
| `headlineMedium` | 28px | SemiBold | 36px | Main screen headers |
| `titleLarge` | 22px | Medium | 28px | App bars, card titles |
| `bodyMedium` | 14px | Regular | 20px | Default body copy |
| `labelLarge` | 14px | Medium | 20px | Button labels, chip text |

---

## 4. Responsive Breakpoints & Multi-Platform Adaptation

| Form Factor | Breakpoint Window | Navigation Paradigm | Layout Strategy |
|---|---|---|---|
| **Compact (Mobile)** | Width < 600dp | Bottom `NavigationBar` | Single-column scroll (`ListView` / `Column`) |
| **Medium (Tablet / Foldable)** | 600dp ≤ Width < 840dp | `NavigationRail` | Two-pane split view or adaptive grid |
| **Expanded (Desktop / Web)** | Width ≥ 840dp | Permanent `NavigationDrawer` | Master-detail split layout with max content width constraint |

### Max Content Width Constraint
On expanded desktop/web viewports, content containers must specify `constraints: BoxConstraints(maxWidth: 1200)` and be horizontally centered using `Center()` to avoid excessively wide text lines.

---

## 5. Micro-Interactions & Transitions
- Button presses must provide subtle tactile feedback (Haptic feedback on mobile).
- State transitions must employ smooth `AnimatedSwitcher` or `AnimatedContainer` with 200–300ms durations and `Curves.easeInOut`.
