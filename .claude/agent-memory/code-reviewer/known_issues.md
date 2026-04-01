---
name: Known Recurring Issues
description: Violation patterns found in the full project review on 2026-03-27. Check these categories first on future reviews.
type: project
---

Found in full review on 2026-03-27.

**Why:** These are patterns that appear across multiple files and should be checked first in future reviews.
**How to apply:** Grep for these patterns first when reviewing new code to quickly find violations.

## Recurring Issues

### Native .alert() instead of router.showAlert()
Multiple views use SwiftUI's native `.alert()` modifier directly. Rule requires `router.showAlert()`.
Files: ProfileView, CheckInView, SessionEntryView, SessionsView, SessionDetailView, GoalsPlanningView, GymSetupView.

### Raw Button() in Views
Some views use raw `Button()` wrapper instead of `.anyButton()` / `.asButton()`.
Notable: SettingsView.swift `settingsRow()` helper uses `Button(action:)`. SessionEntry toolbar buttons, etc.
Rule: ALWAYS use `.anyButton()` or `.asButton()` instead of raw `Button()`.

### AddScheduleView is a VIPER violation
`AddScheduleView` receives `interactor: any ClassScheduleInteractor` directly and calls business logic (`save()`) inside the View. Has `@State` for all form data and business logic. No Presenter. Missing analytics tracking.

### OnboardingView uses Spacer()
Several pages in OnboardingView use raw `Spacer()` for layout instead of `.frame(maxWidth: .infinity, alignment:)`.

### Missing login/logout coordination for BJJ managers
RESOLVED as of 2026-04-01. `CoreInteractor+Shared.swift` now calls `sessionManager`, `beltManager`, `goalManager`, and `achievementManager` `.logIn(userId:)` synchronously after the async block, and `.logOut()` / `.clearAll()` in `signOut()`. `LiveActivityManager` does not need login coordination (no user data).

### Single preview for some screens
Some screens only have one `#Preview` block (e.g., GymSetupView only shows "Add Gym", no "Edit Gym" state; TrainingStatsView only one preview). AchievementsView now has two previews as of 2026-04-01, but both are functionally identical (same signed-in container, no earned-vs-empty distinction in data).
