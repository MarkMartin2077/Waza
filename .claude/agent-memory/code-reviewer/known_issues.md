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
Some screens only have one `#Preview` block (e.g., TrainingStatsView only one preview). AchievementsView has two previews but both use the same signed-in container — no earned-vs-empty distinction. GymSetupView now has two previews (Add + Edit) as of latest commit.

### Native .sheet() in GoalsPlanning and Achievements
GoalsPlanningView uses `.sheet(isPresented: $presenter.showAddGoalSheet)` and AchievementsView uses `.sheet(item: $presenter.selectedAchievement)` — native sheet instead of `router.showScreen(.sheet)`. TabBarView also uses a native `.sheet()` for the geofence check-in prompt. These are intentional UI-state-driven sheets but technically violate the no-native-alert/sheet rule.

### Force unwraps on static URL strings
WelcomeView.swift and SettingsView.swift force-unwrap `URL(string:)!` for hardcoded constant strings (termsOfService, privacyPolicy, App Store URL). Low crash risk in practice but violates the no-force-unwrap rule.

### SettingsPresenter unowned self captures in alert callbacks
SettingsPresenter.onDeleteAccountPressed() and showDeleteAccountReauthAlert() use `self.methodName()` inside `Button` closures nested in `router.showAlert()`. These are strong captures; no `[weak self]` guard. Since alerts are modal, presenter stays alive, so this is low actual risk — but pattern differs from other screens that use `[weak self]` explicitly.

### TrainingStatsView "Progress - Empty State" preview is not empty
Both #Preview blocks use the same signed-in DevPreview container, so the "Empty State" preview shows the same data as the main one.

### DashboardPresenter hoursThisWeekFormatted uses live DateRange.thisCalendarWeek
`hoursThisWeekFormatted` calls `DateRange.thisCalendarWeek` inline — this computes fresh each call so the frozen-DateRange bug does NOT apply here. `DateRange.thisCalendarWeek` is a static computed var that computes `Date()` fresh each time.
