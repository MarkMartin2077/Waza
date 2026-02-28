# Waza — Design Audit
*Goal: Apple Design Award contender*

---

## Bottom Line

The app is well-structured and functional, but currently looks like every other iOS productivity app built with SwiftfulUI defaults. There is no visual identity, no motion language, no moments of delight, and no signature experience that would make it stand out in a category review — let alone an Apple Design Award. That's fixable, but it requires intentional rethinking of the experience, not just polish.

---

## 1. No Visual Identity

Every screen uses `.ultraThinMaterial` cards on a system background with `.accent` color highlights. No personality. You'd never identify a screenshot as "Waza" with the icon cropped out.

**The untapped opportunity:** BJJ has a rich visual vocabulary — the belt system is a graduation ceremony built into the sport. White → Blue → Purple → Brown → Black is one of the most recognizable progressions in any martial art. The app never uses this. The entire color system could dynamically shift to reflect the user's belt rank. A white belt user's app feels clean and sparse. A black belt's app feels bold and saturated. Every promotion is a visual milestone the user actually sees.

---

## 2. Dashboard is the App's Weakest Screen

The primary screen users see every single day shows a one-line stat strip and a list of sessions. The streak and session count are displayed as plain text with a bullet separator — these are the two core motivation loops and they deserve visual weight. No sense of momentum, no time-of-day awareness, no hierarchy between the upcoming class card and ordinary session rows.

**What it should feel like:** Open at 7am and it greets you with your streak foregrounded, your class in 2 hours prominent, and your last session's key insight surfaced. Open Sunday evening and it shows a weekly summary ring. The screen should be alive and contextual.

---

## 3. Motion Language is Essentially Absent

Every animation uses `.easeInOut(duration: 0.2)` or `.easeInOut(duration: 0.4)` — the same value applied uniformly. This produces motion that feels mechanical.

**What's needed:**
- **Springs** for interactive elements (`.spring(response: 0.3, dampingFraction: 0.7)`)
- **Staggered list appearance** — rows appearing with sequential delay offset creates depth
- **Shared element transitions** — tapping a session row should carry the session's icon into the detail view via `matchedGeometryEffect`
- **Achievement unlock animation** — currently a silent database write; should involve a scale pop, confetti, and a distinct haptic sequence

---

## 4. Achievement System Feels Like an Afterthought

A `LazyVGrid` of icons. Tapping does nothing. Locked achievements are invisible — no sense of "what could I earn?" No unlock moment, no rarity, no narrative weight. Earning an achievement is visually identical to nothing happening.

Achievements should feel like physical medals. The unlock moment should be the most emotionally resonant interaction in the app.

---

## 5. The Check-In Moment is Wasted

Checking in to class is the central ritual of the app — the user physically showed up. That is a big deal in a discipline where consistent attendance is everything. The current confirmation state is a green checkmark icon and some text.

**What it should be:**
- A full-screen transition with the belt color erupting from the center
- A strong, composed haptic sequence (not just `.success`)
- The streak counter incrementing with a spring animation
- AI encouragement text streaming in as the animation settles
- A contextual summary: "You've trained X times this week"

---

## 6. The Belt Gets an 80×80 Circle with a Letter

The belt is what BJJ practitioners identify with most deeply. Getting promoted is one of the most significant events in a practitioner's life. The app represents it as a circle with the first letter of the belt color and a 15% opacity background fill.

**What it deserves:**
- The belt rendered visually with actual stripes
- A promotion history that reads as a milestone timeline, not a list with dividers
- The promotion date displayed with ceremony — "Promoted to Blue Belt · March 2023 · 847 days as white belt"

---

## 7. Session Logging Prioritizes Completeness Over Speed

Seven collapsible sections accessed via chevron toggles. This is the thoroughness of a spreadsheet, not the fluidity of a training companion. Most sessions, the user wants: date, type, duration, maybe a note.

**Better pattern:** A quick-log card at the top (type + duration, two taps to log), with "Add more details" expanding the full form for sessions where the user wants to reflect. The current form treats every field as equally important.

---

## 8. Typography Has No Personality

The entire app uses SF Pro with system size tokens. Section headers, numbers, labels — everything is weighted the same way. The numbers (session counts, streak days, training time) are the most emotionally resonant data in the app and should be typographically celebrated. The welcome screen's 48pt hero title suggests an understanding that typography can have presence — that ambition disappears entirely inside the app.

---

## 9. Inconsistent Card Backgrounds

The Training Stats screen uses `Color(.systemGray6)` for stat cards. Every other screen uses `.ultraThinMaterial`. One is flat, one is translucent — they look meaningfully different. A user switching between Dashboard and Progress feels like they've changed apps. Padding values also vary without system (12pt, 14pt, 16pt used interchangeably on visually similar cards).

---

## 10. Empty States Are All Identical

Every empty state is `ContentUnavailableView` + a system icon + generic text. This is iOS 17's lazy default. An empty dashboard for a new user is your second onboarding moment — it should tell them what to do next, make the action obvious, and ideally preview what the filled screen looks like. The current approach gives them a small icon and gray text.

---

## 11. AI Insights is Hidden

The most innovative feature in the app is accessed via a small brain icon in the dashboard's navigation bar. Most users will never tap it. The feature should surface contextually — after the 10th logged session, a card appears: "Your AI coach has new observations." After a week of good attendance, a summary appears automatically. Hiding AI behind a toolbar button treats it as a utility. It should behave like a coach.

---

## 12. No Platform Integration That Distinguishes the App

Recent Apple Design Award winners make exceptional use of platform-specific features. Waza uses none of them:

- **Live Activities / Dynamic Island:** A class countdown timer on the Dynamic Island when class is 30 minutes away. Tapping opens the check-in flow directly. No other BJJ app does this.
- **Home Screen Widgets:** Today's class + streak + weekly ring. Puts the app on the home screen permanently.
- **App Intents / Siri:** "Hey Siri, log a session" / "Start my gi class"
- **StandBy Mode:** Clock face showing today's class time
- **Spring animations:** The app targets iOS 17+ but never uses `withAnimation(.spring)`

---

## 13. Tab Bar Icons Conflict with Empty State Icons

The Sessions tab icon (`figure.martial.arts`) is the same symbol used in the empty state illustrations inside the app. The icon that means "go to sessions" and the icon that means "you have no sessions" are visually identical.

---

## 14. Settings Footer Shows "2024 Developer, LLC"

Stale placeholder copy. Details matter in a design review.

---

## Priority Order

### Highest impact, most urgent
1. Visual identity — belt-driven color system, typographic personality
2. Dashboard redesign — contextual, alive, motivating
3. Check-in moment — make it feel earned with animation + haptics
4. Achievement unlock — make earning feel real

### High impact, mid effort
5. Session logging — quick-log primary, detailed-log secondary
6. Belt visualization — render actual belt with stripes
7. Motion language — springs, stagger, shared element transitions
8. Empty states — narrative, illustrated, directive

### High differentiator, significant effort
9. Live Activities + Dynamic Island integration
10. Home screen widgets
11. Contextual AI surfacing (not behind a toolbar button)
12. App Intents / Siri support
