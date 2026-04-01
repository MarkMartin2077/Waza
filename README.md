# Waza

A BJJ training tracker for iOS. Log sessions, check in at your gym, track progress, and get AI-powered insights on your training.

## Features

**Session Logging**
- Log training sessions with type (Gi, No-Gi, Open Mat, Competition, Drilling, Private Lesson)
- Tag focus areas (Guard, Passing, Takedowns, Sweeps, Submissions, Escapes + custom)
- Structured reflection: what worked, what to improve, key insights
- Pre/post session mood tracking and round count

**Gym Check-In**
- Automatic geofence detection when you arrive at your gym
- Manual check-in from any tab
- Mood capture and AI-generated encouragement on check-in
- Live Activity timer on the Lock Screen during training

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
- Daily training streaks
- Achievement system with unlock celebrations
- Experience points tracking

**Widgets**
- Streak widget for home screen
- Next class widget showing upcoming scheduled session
- Training timer Live Activity

## Architecture

VIPER + RIBs pattern. Each screen has four files:

```
View       → UI only, displays presenter state
Presenter  → Business logic, calls interactor and router
Interactor → Data access through managers
Router     → Navigation
```

Core coordination through `CoreBuilder`, `CoreRouter`, and `CoreInteractor`.

## Project Structure

```
Waza/
├── Core/              # All screens (Sessions, Progress, Profile, CheckIn, etc.)
├── Managers/          # Service layer (BJJ, Auth, Purchases, ClassSchedule, etc.)
├── Components/        # Reusable UI (views, modals, view modifiers)
├── Extensions/        # Swift type extensions
├── Utilities/         # Constants, keys, helpers
├── Root/              # App entry, dependencies, RIBs
└── SupportingFiles/   # Assets, plists
WazaWidgets/           # Home screen widgets + Live Activity
```

## Build Configurations

| Scheme | Firebase | Use Case |
|--------|----------|----------|
| Mock | None | Fast development, mock data |
| Development | Dev project | Integration testing |
| Production | Prod project | Release builds |

Use **Mock** for most development. Switch to Dev/Prod for Firebase integration testing.

## Tech Stack

- **UI**: SwiftUI, SwiftfulUI, SwiftfulRouting
- **Backend**: Firebase (Auth, Firestore, Analytics, Crashlytics, Cloud Messaging)
- **Auth**: Firebase Auth (Anonymous, Apple, Google sign-in)
- **Purchases**: RevenueCat
- **Analytics**: Firebase Analytics, Mixpanel
- **AI**: Apple Intelligence (on-device)
- **Location**: CoreLocation geofencing
- **Widgets**: WidgetKit, ActivityKit
- **Images**: SDWebImageSwiftUI
- **Haptics**: SwiftfulHaptics
- **Gamification**: SwiftfulGamification

## Getting Started

1. Clone the repo
2. Open `Waza.xcodeproj` in Xcode
3. Select the **Waza - Mock** scheme
4. Build and run

Mock scheme requires no Firebase setup and uses in-memory data.

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+
