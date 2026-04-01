---
name: Waza Project Overview
description: High-level architecture facts about the Waza BJJ tracking app for efficient future reviews
type: project
---

Waza is an iOS BJJ (Brazilian Jiu-Jitsu) training tracker using VIPER+RIBs, Swift 6, SwiftUI.

**Why:** Persistent context needed across review sessions to avoid re-discovering the same structural facts.
**How to apply:** Use this as a map when navigating the codebase for reviews or feature work.

## Key Paths
- Screens: `Waza/Core/<ScreenName>/`
- Managers: `Waza/Managers/`
- CoreInteractor extensions: `Waza/Root/RIBs/Core/CoreInteractor+*.swift`
- Dependencies init: `Waza/Root/Dependencies/Dependencies.swift`
- DevPreview: also in `Dependencies.swift` (same file, bottom half)

## Screens (as of 2026-03-27)
Dashboard, Sessions, SessionDetail, SessionEntry, CheckIn, TrainingStats, GoalsPlanning, AIInsights, Achievements, Profile, Settings, ClassSchedule, GymSetup, AddSchedule (standalone component), Onboarding, Welcome, CreateAccount, Paywall, TabBar, AppView, DevSettings

## Managers (custom, beyond starter template)
SessionManager, BeltManager, GoalManager, AchievementManager, TrainingStatsManager, AIInsightsManager, ClassScheduleManager, LiveActivityManager — all in `Waza/Managers/BJJ/` and `Waza/Managers/ClassSchedule/` and `Waza/Managers/LiveActivity/`

## CoreInteractor
Split into extension files: `+Managers`, `+BJJ`, `+Gamification`, `+ClassSchedule`, `+Shared`, `+LiveActivity`. All managers are public properties in the struct.

## Notable Architecture Decisions
- Managers are stored as concrete types in CoreInteractor struct (not private), which is intentional for the pattern used here.
- Login coordination lives in `CoreInteractor+Shared.swift` (logIn/signOut).
- BJJ managers (Session, Belt, Goal, Achievement) use a custom sync pattern, not SwiftfulDataManagers.
