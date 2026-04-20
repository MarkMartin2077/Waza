# Design Migration Plan: Editorial Ink & Paper

**Goal:** Incrementally shift Waza's visual language from the current gamified/material aesthetic toward the editorial, restraint-first "ink & paper" design — using only native SwiftUI system fonts, supporting dark mode, and maintaining accessibility.

**Guiding Principles:**
- Use system fonts with `.serif`, `.monospaced`, and `.default` designs (no bundled fonts)
- Every color must have a light + dark variant
- Minimum 4.5:1 contrast for body text, 3:1 for large text (WCAG AA)
- Keep iOS-native interaction patterns (no alien gestures)
- Each phase is shippable on its own — no phase depends on completing all later phases

---

## Design Language Translation (Mockup → Native SwiftUI)

| Mockup Element | Native SwiftUI Equivalent |
|---|---|
| Instrument Serif (display) | `.system(.largeTitle, design: .serif)` with varying weights |
| Geist Mono (labels) | `.system(.caption, design: .monospaced)` |
| Geist (body) | `.system(.body, design: .default)` (standard SF Pro) |
| Shippori Mincho (kanji) | System font — kanji renders fine in SF Pro |
| Paper #f4efe6 | Semantic color with dark counterpart |
| Ink scale | Custom warm gray scale, adaptive |
| Tatami red #c8412a | Single accent, works in both modes |
| Tatami weave texture | Subtle `Canvas` or `GeometryReader` pattern |
| .ultraThinMaterial | Keep for select surfaces, replace most with solid colors |
| RoundedRectangle(16-20) | Reduce to 4-8pt for editorial feel |
| Hanko stamps | SwiftUI `View` with kanji + colored background |

---

## Phase 0: Foundation (Design Tokens)

**What:** Update the existing token files to support the new palette without breaking any current screens. Add the new tokens alongside existing ones, then migrate screen by screen.

### 0A — Color Palette

Create an adaptive color system. Light mode gets the warm paper/ink tones; dark mode gets inverted equivalents.

```
Light Mode                    Dark Mode
─────────────────────────────────────────────────
paper:     #F4EFE6            inkDark:   #13110E (near-black)
paperHi:   #FAF6ED            inkDarkHi: #1E1B17
ink100:    #ECE4D4            ink100:    #2A2620
ink200:    #E0D9CB            ink200:    #3A3530
ink300:    #C4BDAE            ink300:    #5A5348
ink400:    #9A9285            ink400:    #7A7268
ink500:    #726A5F            ink500:    #9A9285
ink600:    #45403A            ink600:    #C4BDAE
ink700:    #2A2620            ink700:    #E0D9CB
ink800:    #1E1B17            ink800:    #ECE4D4
ink900:    #13110E            ink900:    #F4EFE6
─────────────────────────────────────────────────
tatami:    #C8412A            tatami:    #E8654A (slightly lighter for dark bg)
tatami300: #E68975            tatami300: #E68975
```

Implementation: Add these as `Color` extensions using `UIColor { traitCollection in ... }` for automatic light/dark switching.

### 0B — Typography Scale

Replace `WazaFont` with a richer scale using system font designs:

| Token | Size | Weight | Design | Usage |
|---|---|---|---|---|
| `wazaDisplayLarge` | 44pt | regular | .serif | Hero greeting, report headlines |
| `wazaDisplayMedium` | 28pt | regular | .serif | Section titles, screen intros |
| `wazaDisplaySmall` | 20pt | regular | .serif | Card titles, technique names |
| `wazaNum` | 72pt | light | .monospaced | Big stats (streak count) |
| `wazaNumMedium` | 44pt | light | .monospaced | Secondary stats |
| `wazaNumSmall` | 20pt | regular | .monospaced | Inline numbers |
| `wazaLabel` | 10pt | semibold | .monospaced | ALL-CAPS section labels (tracking: +0.15em) |
| `wazaBody` | 15pt | regular | .default | Body text |
| `wazaCaption` | 12pt | regular | .default | Supporting text |

Note: 10pt label is below Apple's recommended minimum for *body* text, but it's acceptable for uppercase decorative labels with high contrast (ink900 on paper). Add `accessibilityFont` fallback that maps to `.caption2` for Dynamic Type.

### 0C — Corner Radius

Reduce the radius scale to feel more editorial/printed:

| Token | Current | New | Usage |
|---|---|---|---|
| `wazaCornerSmall` | 12pt | 4pt | Chips, pills, inline elements |
| `wazaCornerStandard` | 16pt | 8pt | Cards, rows, containers |
| `wazaCornerHero` | 20pt | 12pt | Featured surfaces |

### 0D — Spacing (unchanged)

The current spacing scale (4/8/12/16/20/24) works perfectly with the new design. No changes needed.

---

## Phase 1: Accent Color + Background Warmth

**What:** Ship the single most impactful visual change — swap the cold indigo accent for tatami red, and warm up the background from pure system gray to the paper tone.

**Files to modify:**
- `Color+EXT.swift` — change `wazaAccent` hex, add paper/ink semantic colors
- `ColorScheme+EXT.swift` — update `backgroundPrimary`/`backgroundSecondary` to use warm tones

**Impact:** Every screen updates immediately since they all reference `Color.wazaAccent` and the background extensions.

**Risk:** Low. Pure token swap. Verify contrast of red accent on both paper (light) and dark backgrounds.

**Estimated scope:** ~1 hour

---

## Phase 2: Typography Shift

**What:** Replace the rounded/black typography (current "gamified" feel) with the serif/mono split. Hero numbers become light-weight monospaced. Section labels become small uppercase mono. Display text becomes serif.

**Files to modify:**
- `WazaFont.swift` — redefine all font tokens
- All components that use `.wazaHero`, `.wazaStat`, `.wazaTitle`, etc. (grep for usages)

**Approach:**
1. Redefine tokens in `WazaFont.swift`
2. Add a `.wazaLabelStyle()` ViewModifier that applies: monospaced + uppercase + tracking + ink500 color
3. Grep for direct `.font(.system(...))` usage in views and replace with tokens

**Key decisions:**
- Serif display text gives the "editorial" feel immediately
- Light-weight monospaced numbers (not black/rounded) feel more refined
- The ALL-CAPS mono label pattern creates the journal/editorial rhythm

**Estimated scope:** ~2-3 hours (many files reference fonts)

---

## Phase 3: Surface Treatment — Cards & Containers

**What:** Replace `.ultraThinMaterial` + 16pt radius with solid warm surfaces + thin borders + smaller radius. This is where the "page of a journal" feel comes in.

**Current pattern:**
```swift
.background(
    RoundedRectangle(cornerRadius: .wazaCornerStandard)
        .fill(.ultraThinMaterial)
)
```

**New pattern:**
```swift
.background(
    RoundedRectangle(cornerRadius: .wazaCornerStandard)
        .fill(Color.wazaPaperHi)
        .overlay(
            RoundedRectangle(cornerRadius: .wazaCornerStandard)
                .strokeBorder(Color.wazaInk300, lineWidth: 0.5)
        )
)
```

**Alternative for dark-on-dark containers (challenge cards, etc.):**
```swift
.background(
    RoundedRectangle(cornerRadius: .wazaCornerStandard)
        .fill(Color.wazaInk900)
)
```

**Files to modify:**
- `DashboardXPBadgeView.swift`
- `WeeklyChallengesCardView.swift`
- `SessionRowView.swift`
- `UpcomingClassCardView.swift`
- Any other component using `.ultraThinMaterial`

**Decision:** Don't remove ALL materials — keep `.ultraThinMaterial` for overlays, toasts, and modals where translucency adds value. Remove it from card surfaces where a solid paper background is more appropriate.

**Estimated scope:** ~2 hours

---

## Phase 4: The Hanko Component

**What:** Create the signature hanko stamp component. This is the single most brand-defining element from the design. Use it for:
- Session type indicators (replacing SF Symbol icons)
- Achievement badges
- Navigation decorators

**Implementation:**
```swift
struct HankoView: View {
    let kanji: String
    var size: CGFloat = 44
    var rotation: Double = -2
    var color: Color = .wazaTatami
    var inkColor: Color = .wazaPaperHi
    
    var body: some View {
        Text(kanji)
            .font(.system(size: size * 0.5))
            .foregroundStyle(inkColor)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
            )
            .rotationEffect(.degrees(rotation))
    }
}
```

**Kanji mappings for session types:**
| Session Type | Kanji | Meaning |
|---|---|---|
| Gi | 技 | technique |
| No-Gi | 体 | body |
| Open Mat | 道 | way/path |
| Competition | 試 | test |
| Drilling | 練 | practice |
| Private | 師 | teacher |

**Where to use first:**
- `SessionRowView` — replace the current icon container with a hanko
- Dashboard "Recent Practice" list

**Estimated scope:** ~1-2 hours

---

## Phase 5: Dashboard Layout Refresh

**What:** Reorganize the dashboard to match the new information hierarchy. The design puts greeting → XP/belt strip → streak hero → weekly grid → challenge → CTA in a clear vertical flow separated by thin rules (not cards floating on gray).

**Key changes:**
1. Replace card-based layout with **ruled sections** (thin `Divider()` borders between sections instead of floating cards)
2. Move the streak number to hero size (72pt monospaced, tatami-colored)
3. Add the **weekly practice grid** (Mon-Sun with hanko stamps for completed days)
4. Style the log session CTA as a full-width tatami-red button
5. Add secondary actions below: "Quick check-in" / outline buttons

**What NOT to change:**
- Keep the existing data flow (Presenter → View)
- Keep scaleAppear animations
- Keep DashboardXPBadgeView consolidation (it's good architecture)

**Estimated scope:** ~3-4 hours

---

## Phase 6: Session Entry Reskin

**What:** Update the session logging screen to use the 2x3 grid selector with kanji, the mono duration picker, technique chips, and the "Press the seal" save button.

**Key changes:**
1. Session type picker → 2x3 grid with kanji character + label + subtitle
2. Duration picker → large monospaced number + chip row (30/45/60/75/90/120)
3. Technique tags → chips with × dismiss
4. Notes field → serif-styled text editor
5. Mood before/after → keep existing slider, restyle with ink/paper tokens
6. Save button → tatami red, full-width, "Press the seal · +XP"

**Estimated scope:** ~3-4 hours

---

## Phase 7: Technique Journal & Monthly Report Polish

**What:** Apply the editorial styling to these two screens which already exist.

### Technique Journal:
- Add the "progression map" horizontal bar (Learning → Drilling → Applying → Polishing)
- Style technique rows with stage-colored indicators
- Add filter chips at top

### Monthly Report:
- Dark background variant (ink900)
- Editorial large serif headline ("You showed up eighteen times.")
- Attendance calendar with hanko stamps for trained days
- Keep existing data — just restyle the presentation

**Estimated scope:** ~4-5 hours total

---

## Phase 8: Profile & Tab Bar

**What:** Final visual alignment.

### Profile:
- Hanko avatar (kanji in square, belt-colored seal overlay)
- Belt progression strip (6 color blocks: white → blue → purple → brown → black → coral)
- Achievement "seals earned" grid with hanko stamps
- Navigation rows with kanji icon containers

### Tab Bar:
- Keep standard `TabView` (iOS native, accessible)
- Consider custom tab labels with kanji *above* the English label (not replacing it)
- Or simply keep SF Symbols — the editorial feel comes from the screen content, not the tab bar

**Decision point:** Custom tab bar is high effort and fights iOS conventions. Recommend keeping the standard tab bar and letting the screen content carry the brand. Revisit if custom fonts are added later.

**Estimated scope:** ~3-4 hours

---

## Phase 9 (Future): Advanced Elements

These are NOT part of the initial migration but noted for future consideration:

- **Tatami weave texture** — subtle repeating pattern via `Canvas` view
- **Custom fonts** — bundle Instrument Serif + Geist Mono when ready
- **Check-In screen** — new feature requiring CoreLocation (separate feature plan)
- **AI Insights** — new feature (separate scope entirely)
- **"Hold to press" haptic interaction** — custom long-press gesture with haptic feedback

---

## Migration Order & Dependencies

```
Phase 0 (tokens) ← foundation for everything
    ↓
Phase 1 (accent + bg) ← instant visual refresh, 1 hour
    ↓
Phase 2 (typography) ← second biggest impact
    ↓
Phase 3 (surfaces) ← completes the "paper" feel
    ↓
Phase 4 (hanko) ← brand identity element
    ↓
Phase 5-8 can be done in any order (screen-by-screen)
```

**Minimum Viable Redesign:** Phases 0-3 (~6-8 hours) give you 80% of the new feel across the entire app with minimal screen-level changes.

---

## Dark Mode Strategy

The design mockups only show light mode. Here's how to handle dark:

| Element | Light | Dark |
|---|---|---|
| Background | Warm paper (#F4EFE6) | Warm near-black (#13110E) |
| Card surface | Bright paper (#FAF6ED) | Elevated dark (#1E1B17) |
| Primary text | Near-black (#13110E) | Warm white (#F4EFE6) |
| Secondary text | Mid gray (#726A5F) | Mid gray (#9A9285) |
| Borders | Warm gray (#C4BDAE) | Dark gray (#2A2620) |
| Accent (tatami) | #C8412A | #E8654A (10% lighter for legibility) |
| Ink-on-dark cards | White on #13110E | Same (already dark-mode native) |

**Implementation:** Use `UIColor { trait in }` initializer for all semantic colors. This gives automatic switching without any `@Environment(\.colorScheme)` checks in views.

---

## Accessibility Checklist

- [ ] All text meets WCAG AA contrast (4.5:1 body, 3:1 large)
- [ ] `wazaLabel` (10pt mono) has accessibilityFont fallback for Dynamic Type XXL
- [ ] Hanko kanji characters have `.accessibilityLabel` (e.g., "Gi session" not "技")
- [ ] Tatami red (#C8412A) on paper (#F4EFE6) = 4.8:1 contrast (passes AA)
- [ ] Tatami light (#E8654A) on dark (#13110E) = 4.6:1 contrast (passes AA)
- [ ] No information conveyed by color alone (hanko + text labels always paired)
- [ ] Standard iOS navigation patterns maintained (back buttons, tab bar, sheets)

---

## What We're Keeping

- VIPER architecture (no changes)
- All managers and data flow (no changes)
- SwiftfulRouting navigation (no changes)
- Spring animations and `.scaleAppear` (keep, they feel editorial too)
- Standard `TabView` (accessibility + iOS convention)
- Standard `NavigationStack` behavior
- The XP/streak/challenge systems (just restyled)

---

## Success Criteria

After Phases 0-4, the app should feel like:
> "A personal practice journal that happens to be an app"

Not like:
> "A gamified fitness tracker with achievements"

The data is the same. The gamification still works. But the *presentation* shifts from "game UI" to "craft tool."
