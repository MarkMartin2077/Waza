# Waza Improvement Plan

Generated: April 13, 2026

This document captures the prioritized list of improvements identified after shipping the 5 major features (XP Levels, Share Cards, Weekly Challenges, Monthly Report, Technique Journal). Each item includes context, affected files, and priority.

---

## Priority 1: Test Coverage Gaps

### 1.1 ChallengeGenerator Tests
**Why:** The most complex pure-logic path in the app (weighted selection, category enforcement, smart history analysis) has zero tests. A single regression here silently breaks the weekly experience for every user.

**Files to test:**
- `Managers/BJJ/ChallengeGenerator.swift` — test `generate()` with various session histories
- Test cases: zero sessions (beginner defaults), single session type (skip logSessionType), single gym (skip trainAtDifferentGym), seeded RNG for deterministic selection, category variety enforcement

**Files to create:**
- `WazaUnitTests/ChallengeGeneratorTests.swift`

### 1.2 ChallengeManager Evaluation Tests
**Why:** The evaluation logic handles 8 challenge types with different counting semantics. Backdated sessions, edge-of-week boundaries, and the "once completed stays completed" rule all need verification.

**Files to test:**
- `Managers/BJJ/ChallengeManager.swift` — test `evaluate()` per challenge type
- Test cases: trainXTimes counting, miniStreak consecutive day detection, logSessionType matching, newFocusArea with recent areas in metadata, trainAtDifferentGym with primary gym comparison

**Files to create:**
- `WazaUnitTests/ChallengeManagerTests.swift`

### 1.3 MonthlyReportData Assembly Tests
**Why:** The report aggregates data from 6+ managers. Mood averages with nil values, gym distribution with empty academies, longest streak computation, and month-over-month comparison with zero-session months are all edge cases.

**Files to test:**
- `Root/RIBs/Core/CoreInteractor+BJJ.swift` — `getMonthlyReportData(for:)` and its helpers
- Test cases: zero sessions, single session, mood nil handling, gym distribution with nil academies, month-over-month with empty previous month

**Files to create:**
- `WazaUnitTests/MonthlyReportTests.swift`

### 1.4 TechniqueManager Tests
**Why:** ensureTechniquesExist uses case-insensitive matching and category inference. A regression here creates duplicates or miscategorized techniques.

**Files to test:**
- `Managers/BJJ/TechniqueManager.swift` — CRUD, ensureTechniquesExist, category inference
- Test cases: case-insensitive dedup, category inference for preset names, uncategorized fallback

**Files to create:**
- `WazaUnitTests/TechniqueManagerTests.swift`

---

## Priority 2: Feature Cross-Pollination

### 2.1 Technique-Aware Challenges
**Why:** The technique journal and weekly challenges exist in parallel. Connecting them creates compound engagement — users are motivated to use both features together.

**Implementation:**
- Add new `ChallengeType.promoteTechnique` — "Promote a technique to the next stage"
- Add new `ChallengeType.practiceWeakTechnique` — "Practice a technique still in Learning stage"
- Update `ChallengeGenerator` to check `TechniqueManager` data when building candidates
- Update `ChallengeManager.evaluate()` to check technique stage changes

**Files to modify:**
- `Managers/BJJ/Models/WeeklyChallengeModel.swift` — add enum cases
- `Managers/BJJ/ChallengeGenerator.swift` — add candidates with technique-based weights
- `Managers/BJJ/ChallengeManager.swift` — add evaluation logic for new types
- `Root/RIBs/Core/CoreInteractor+Challenges.swift` — pass technique data to generator context

### 2.2 Monthly Report Challenge Stats
**Why:** The monthly report doesn't mention challenge completion, which is a major engagement metric users would want to see in their recap.

**Implementation:**
- Add `challengesCompleted: Int` and `challengesSweepCount: Int` to `MonthlyReportData`
- Query `ChallengeManager` for completed challenges in the report month
- Add a "Challenges" row to the summary footer section

**Files to modify:**
- `Managers/BJJ/Models/MonthlyReportData.swift` — add fields
- `Root/RIBs/Core/CoreInteractor+BJJ.swift` — aggregate challenge data in `getMonthlyReportData`
- `Core/MonthlyReport/MonthlyReportView.swift` — add challenges to summary footer

### 2.3 Monthly Report Technique Progression
**Why:** The report shows top focus areas but not technique stage changes. "You promoted Triangle to Applying" is exactly the kind of milestone that makes a monthly report feel personal.

**Implementation:**
- Add `techniquesPromoted: Int` to `MonthlyReportData`
- Track stage changes with dates on `TechniqueModel` (partially exists via `lastStageChangeDate`)
- Filter promotions within the report month

**Files to modify:**
- `Managers/BJJ/Models/MonthlyReportData.swift`
- `Root/RIBs/Core/CoreInteractor+BJJ.swift`
- `Core/MonthlyReport/MonthlyReportView.swift`

---

## Priority 3: Gamification Discoverability

### 3.1 First-Session Gamification Onboarding
**Why:** New users have no idea XP, levels, challenges, or the technique journal exist. The features are deep but invisible until stumbled upon.

**Implementation:**
- After first session save, show a one-time modal explaining: "You earned XP! Here's how leveling works."
- On first Dashboard load with challenges, show a tooltip: "New weekly challenges — complete them for rewards"
- Use UserDefaults flags to track which onboarding tips have been shown

**Files to create:**
- `Components/Views/GamificationOnboardingView.swift` — a simple tip card
- `Managers/AppState/OnboardingFlags.swift` — UserDefaults-backed flags

**Files to modify:**
- `Core/Dashboard/DashboardPresenter.swift` — check flags, show tips
- `Core/SessionEntry/SessionEntryPresenter.swift` — trigger first-session XP explanation

### 3.2 Dashboard Feature Discovery
**Why:** The technique journal and monthly report are buried in Profile. Users who don't explore Profile miss them entirely.

**Implementation:**
- Add a "Technique Journal" quick-access card on the Dashboard (below challenges)
- Show a "Monthly report ready" banner on Dashboard during the first week of each month
- Both should be dismissible after first interaction

**Files to modify:**
- `Core/Dashboard/DashboardView.swift` — add entry point cards
- `Core/Dashboard/DashboardPresenter.swift` — manage visibility and dismiss state
- `Core/Dashboard/DashboardRouter.swift` — add navigation methods

---

## Priority 4: Visual Differentiation

### 4.1 Screen Identity
**Why:** Every screen uses the same `.ultraThinMaterial` + `RoundedRectangle(cornerRadius: 16)` + `Color.wazaAccent` treatment. The technique journal, monthly report, and profile all look identical. Users can't distinguish screens at a glance.

**Suggestions (design decisions needed):**
- Give the technique journal a distinct color accent (e.g., progression stage colors as section accents)
- Give the monthly report a header gradient or hero image that differentiates it from regular stats
- Use different card corner radii or border treatments per feature context
- Consider section-level accent colors (technique = purple, challenges = orange, XP = cyan)

**Files to consider:**
- `Core/TechniqueJournal/TechniqueJournalView.swift`
- `Core/MonthlyReport/MonthlyReportView.swift`
- `Components/Views/WeeklyChallengesCardView.swift`

### 4.2 Dashboard Information Hierarchy
**Why:** The dashboard shows 6-8 sections with equal visual weight. The most actionable item (log session button) competes with informational items (XP badge, challenges card, streak risk banner).

**Suggestions:**
- Make the log session button sticky/floating rather than inline
- Collapse XP badge and streak risk into a single compact status bar
- Consider progressive disclosure — show challenges expanded only when there's actionable progress

---

## Priority 5: Resilience

### 5.1 Offline Challenge Generation
**Why:** If the app opens offline before managers populate, `generateChallengesIfNeeded()` may produce poor or empty challenges because session history isn't loaded.

**Fix:** Guard `generateIfNeeded` to only run when `sessionManager.sessions` is non-empty or the user has confirmed signed-in state. Retry on next `loadData()` call.

**Files to modify:**
- `Managers/BJJ/ChallengeManager.swift` — add guard
- `Core/Dashboard/DashboardPresenter.swift` — retry logic

### 5.2 Stale Report Data
**Why:** `getMonthlyReportData` reads from in-memory manager caches. If a manager hasn't synced from remote, the report may show incomplete data.

**Fix:** The report already shows whatever is locally available (SwiftData is source of truth). Document this as expected behavior. Consider adding a "Data may be incomplete" note if `isDataStale` flags are set on any contributing manager.

---

## Tracking

| # | Item | Priority | Status |
|---|------|----------|--------|
| 1.1 | ChallengeGenerator tests | P1 | ✅ Done |
| 1.2 | ChallengeManager evaluation tests | P1 | ✅ Done |
| 1.3 | MonthlyReportData tests | P1 | ✅ Done (MonthlyReportCalculator extracted) |
| 1.4 | TechniqueManager tests | P1 | ✅ Done |
| 2.1 | Technique-aware challenges | P2 | ✅ Done |
| 2.2 | Monthly report challenge stats | P2 | ✅ Done |
| 2.3 | Monthly report technique progression | P2 | ✅ Done |
| 3.1 | First-session gamification onboarding | P3 | ✅ Done (challenges tip + existing XP toast) |
| 3.2 | Dashboard feature discovery | P3 | ✅ Done (journal card + monthly report banner) |
| 4.1 | Screen visual identity | P4 | Design needed |
| 4.2 | Dashboard information hierarchy | P4 | Design needed |
| 5.1 | Offline challenge generation guard | P5 | ✅ Done |
| 5.2 | Stale report data handling | P5 | ✅ Done (documented) |

## Bugs Found & Fixed During P1

Writing tests surfaced two production bugs:

1. **`ChallengeManager.evaluate()` in-memory cache staleness** — the local service was updated
   but `refresh()` was only called when a challenge completed, leaving the observable
   `challenges` array stale. Presenters watching progress would see outdated `currentValue`
   until something completed. Fix: always `refresh()` after evaluation.

2. **`trainDuration` challenge could never complete** — `ChallengeGenerator` produced
   `targetValue: 90` (90 minutes) but `ChallengeManager` evaluated it as binary 1-or-0.
   `1 >= 90` was always false. Fix: `targetValue: 1`, threshold minutes moved to `metadata`;
   evaluation reads threshold from metadata (defaulting to 90).
