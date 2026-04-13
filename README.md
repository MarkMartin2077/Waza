# Waza

A BJJ training tracker for iOS. Log sessions, check in at your gym, track technique progression, earn XP, and get AI-powered insights on your training.

## Features

**Session Logging**
- Log training sessions with type (Gi, No-Gi, Open Mat, Competition, Drilling, Private Lesson)
- Tag focus areas (Guard, Passing, Takedowns, Sweeps, Submissions, Escapes + custom)
- Structured reflection: what worked, what to improve, key insights
- Pre/post session mood tracking and round count
- Search sessions by techniques, notes, academy, instructor
- Filter by session type, gym, and mood
- Sessions grouped by month for time-based browsing

**Gym Check-In**
- Automatic geofence detection when you arrive at your gym
- Manual check-in from any tab
- Mood capture and AI-generated encouragement on check-in
- Live Activity timer on the Lock Screen during training

**XP Levels & Titles**
- 8 ranked leagues (Rookie, Scrapper, Grappler, Contender, Adept, Ace, Vanguard, Grandmaster) with 5 sub-ranks each, plus Legend tier
- Variable XP rewards: session logging, competition bonus, full reflections, mood tracking, new focus areas, check-ins, streak milestones
- XP multipliers: streak tier bonus (+25% to +100%), perfect week (+25%), fire round (random 2x for 24 hours)
- Full-screen celebrations for level-ups, fire round activations, and streak tier promotions
- XP progress bar on profile and compact badge on dashboard
- Active boost timer showing fire round countdown and streak tier status

**Technique Journal**
- Personal technique library that grows automatically from session focus areas
- 4-stage progression tracking: Learning, Drilling, Applying, Polishing
- Techniques grouped by category (Guard, Passing, Takedowns, Submissions, Escapes, Sweeps)
- Visual technique map showing progression via color intensity
- Practice counts, last practiced dates, and promotion suggestions
- Manual technique creation and category editing

**Weekly Challenges**
- 3 personalized challenges generated every Monday based on training history
- Smart selection: challenges target behaviors you've been neglecting
- 8 challenge types: attendance, session type, new focus area, different gym, mood tracking, mini-streak, full reflection, duration
- Tiered rewards: 25 XP per challenge, streak freeze at 2/3, 100 XP sweep bonus at 3/3
- Dashboard card with progress bars and completion tracking

**Monthly Training Report**
- Auto-generated monthly summary with headline stats, streak, type breakdown, technique focus, mood trends, gym distribution, goals, and achievements
- Month-over-month comparison with directional indicators
- Browse reports for the last 6 months via month picker
- Shareable report card for social media
- Push notification on the 1st of each month

**Share Cards**
- Shareable image cards for: session recap, week in review, level up, streak flex, monthly report
- Dark gradient design with Waza branding
- Native iOS share sheet integration

**Progress Tracking**
- Session count, total hours, and average duration by period (week/month/year/all time)
- Session type breakdown
- Training goals with progress indicators
- AI-powered weekly summaries and training insights (Apple Intelligence)

**Class Schedule**
- Add gyms with location search and map pin
- Schedule recurring classes with day/time/type
- Configurable class reminders
- Adjustable geofence radius per gym (50-500m)

**Gamification**
- Daily training streaks with at-risk warnings and freeze prompts
- 13 achievements across 4 categories with unlock celebrations
- Streak risk push notifications and in-app banners

**Widgets**
- Streak widget for home screen
- Next class widget showing upcoming scheduled session
- Training timer Live Activity

## Architecture

VIPER + RIBs pattern. Each screen has four files:

```
View       -> UI only, displays presenter state
Presenter  -> Business logic, calls interactor and router
Interactor -> Data access through managers
Router     -> Navigation via SwiftfulRouting
```

Core coordination through `CoreBuilder`, `CoreRouter`, and `CoreInteractor`. Celebration modals (achievements, level-ups, fire rounds, streak tier-ups) routed via `router.showModal()` with a priority queue in `TabBarPresenter`.

## Project Structure

```
Waza/
├── Core/              # All VIPER screens
│   ├── Dashboard/     # Home tab with XP badge, challenges, streak risk
│   ├── Sessions/      # Session list with search, filters, month sections
│   ├── TrainingStats/  # Progress tab with period picker
│   ├── Profile/       # Profile with XP bar, boosts, monthly report entry
│   ├── TechniqueJournal/ # Technique list + map with progression
│   ├── TechniqueDetail/  # Technique detail with stage editing
│   ├── MonthlyReport/ # Monthly training report
│   ├── SessionEntry/  # Log new session form
│   ├── SessionDetail/ # Session detail with editable reflections
│   ├── CheckIn/       # Gym check-in flow
│   └── ...
├── Managers/
│   ├── BJJ/           # Session, Belt, Goal, Achievement, Technique, Challenge, Stats managers
│   ├── Gamification/  # XP system, multipliers, streak risk, notifications
│   ├── ClassSchedule/ # Gyms, schedules, geofencing, attendance
│   ├── Auth/          # Authentication
│   └── ...
├── Components/
│   ├── Views/         # Reusable components (XP bar, toast, filter bar, share cards, etc.)
│   └── Modals/        # Full-screen celebrations (level-up, fire round, streak tier, achievement)
├── Extensions/        # Swift type extensions + date formatting
├── Utilities/         # Constants, keys, helpers
├── Root/              # App entry, dependencies, RIBs (CoreInteractor, CoreRouter, CoreBuilder)
└── SupportingFiles/   # Assets, plists, Firebase configs
WazaWidgets/           # Home screen widgets + Live Activity
WazaUnitTests/         # Unit tests (XP system, multipliers, session filters, managers)
WazaUITests/           # Flow-based UI tests
```

## Build Configurations

| Scheme | Firebase | Use Case |
|--------|----------|----------|
| Mock | None | Fast development, mock data |
| Development | Dev project | Integration testing |
| Production | Prod project | Release builds |

Use **Mock** for most development. Switch to Dev/Prod for Firebase integration testing. Dev Settings screen (accessible from Dashboard in non-production builds) includes XP multiplier overrides for testing gamification.

## Tech Stack

- **UI**: SwiftUI, SwiftfulUI, SwiftfulRouting
- **Backend**: Firebase (Auth, Firestore, Analytics, Crashlytics, Cloud Messaging)
- **Auth**: Firebase Auth (Anonymous, Apple, Google sign-in)
- **Purchases**: RevenueCat
- **Analytics**: Firebase Analytics, Mixpanel
- **AI**: Apple Intelligence (on-device, requires A17 Pro+)
- **Location**: CoreLocation geofencing
- **Widgets**: WidgetKit, ActivityKit
- **Images**: SDWebImageSwiftUI
- **Haptics**: SwiftfulHaptics
- **Gamification**: SwiftfulGamification (streaks, XP, progress)
- **Persistence**: SwiftData (local), Firebase Firestore (remote sync)

## Getting Started

1. Clone the repo
2. Open `Waza.xcodeproj` in Xcode 26+
3. Select the **Waza - Mock** scheme
4. Build and run on a simulator or device

Mock scheme requires no Firebase setup and uses in-memory data with seeded mock sessions, techniques, and challenges.

## Requirements

- iOS 26+
- Xcode 26+
- Swift 6.2+
