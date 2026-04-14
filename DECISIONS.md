# Architectural Decision Records

Five deliberate engineering decisions made on this project. Each entry is structured as: **context → decision → tradeoffs → alternatives considered**.

These are the choices I'd expect to defend in a senior-level technical interview. They're the ones where the "right answer" is judgment, not syntax.

---

## 1. VIPER + RIBs for screen architecture

**Context.** This app has 15+ screens that share infrastructure (auth, analytics, purchases, gamification managers). With MVVM, every view model needs access to roughly the same dependency surface, which usually leaks into giant constructor parameter lists or a shared service locator used implicitly across the codebase.

**Decision.** Each screen follows VIPER — View / Presenter / Router / Interactor. The Interactor is a protocol with method signatures specific to that screen; a single `CoreInteractor` struct conforms to *all* screen interactor protocols and resolves managers internally. Routing is split the same way — screen-specific `Router` protocols implemented by a shared `CoreRouter`.

**Tradeoffs.**
- *Cost:* Five files per screen instead of two or three. More ceremony for small screens.
- *Benefit:* Every screen explicitly declares what it needs (via its protocol). Removing a manager or feature surfaces the change as compile errors in every affected screen, rather than silently succeeding. Views are pure UI — never see a manager, never know about dependency injection, never have async code in them.
- *Benefit:* Testing is cheap. Mock interactors are trivial because the screen only depends on a narrow protocol, not the full manager graph.

**Alternatives considered.**
- **MVVM + environment-injected dependencies.** Simpler for small apps; gets noisy at 15+ screens. Loses the "every screen declares its surface area" property.
- **TCA (The Composable Architecture).** Legitimate choice. Rejected because the learning curve is steep for interviewers unfamiliar with it, and the project didn't need TCA's state-composition story — most screens are self-contained.
- **Pure SwiftUI with no architecture.** Fine for sample apps. Doesn't scale to the feature count here.

---

## 2. Consolidate `CoreInteractor`: extensions → services

**Context.** The interactor was originally split across 7 domain-grouped extension files (`CoreInteractor+BJJ.swift`, `+Gamification.swift`, `+Challenges.swift`, etc.), totaling ~1,100 lines. This was the inherited structure from the project template.

The grouping by filename *felt* organized but was actually fragmenting two fundamentally different kinds of code:
- **Thin pass-through delegation** (hundreds of 1-line functions: `var currentUser: UserModel? { userManager.currentUser }`)
- **Real cross-manager orchestration** (sign-in touching 8 managers; session logging updating 5; monthly report assembling from 6)

Grouping by domain hid the difference.

**Decision.** Collapse into a single `CoreInteractor.swift` for the thin pass-throughs (sections grouped by `// MARK:`, not filename), and extract the cross-manager orchestration into dedicated `@MainActor` service structs:

- `AccountLifecycleService` — login, logout, account deletion
- `SessionLoggingService` — session creation + XP + streaks + achievements + challenge evaluation + toast firing
- `MonthlyReportBuilder` — report assembly from 6 managers via `MonthlyReportCalculator`

Services receive their managers by constructor injection. `CoreInteractor` builds them once in `init`.

**Tradeoffs.**
- *Cost:* `CoreInteractor.swift` is 860 lines. SwiftLint's `file_length` rule is disabled for just that file with an inline comment explaining why. Scrolling is a minor daily nuisance.
- *Benefit:* The real orchestration is now in focused, testable services. `SessionLoggingService` can be unit-tested by passing mock managers — previously would have required the full interactor graph.
- *Benefit:* Orchestration logic has clear names. "Where does XP calculation live when a session is logged?" is now answerable by filename alone.

**Alternatives considered.**
- **Leave the 7 files alone.** Valid choice. Rejected because the domain grouping obscured the orchestration-vs-delegation distinction. The new structure makes the interesting code *findable*.
- **Push all orchestration *down* into the managers themselves.** Ideal in principle, but some orchestration is intrinsically cross-manager — the session-logging flow legitimately needs to coordinate 5 managers plus AppState. A dedicated service is the honest representation.
- **One giant file with no extraction.** Rejected; lint warnings aside, it'd be illegible.

---

## 3. Pure static enums for aggregation logic

**Context.** `getMonthlyReportData(for dateRange:)` was a 50-line method on `CoreInteractor` that:
1. Queried sessions from `SessionManager`
2. Computed 6+ aggregations (distinct days, longest streak, top focus areas, gym distribution, mood averages, best day)
3. Queried goals / achievements / challenges / techniques / XP from other managers
4. Assembled a `MonthlyReportData` struct

Writing tests required instantiating `CoreInteractor`, which required the full dependency container, which required mocking 15+ managers. Prohibitive.

The same pattern was visible in `ChallengeGenerator.generate(context:)` — a weighted-selection algorithm buried inside `ChallengeManager`, untestable without mocking the challenge persistence layer.

**Decision.** Extract pure-logic aggregations into static `enum` types that take everything they need as parameters. No stored state, no manager references, no async:

```swift
enum MonthlyReportCalculator {
    static func countDistinctDays(in sessions: [BJJSessionModel]) -> Int
    static func computeLongestStreak(in sessions: [BJJSessionModel], range: DateRange) -> Int
    static func computeTopFocusAreas(from sessions: [BJJSessionModel], limit: Int = 5) -> [(name: String, count: Int)]
    // etc
}
```

The `MonthlyReportBuilder` service orchestrates manager queries and then calls the calculator. The calculator is unit-testable without any managers.

**Tradeoffs.**
- *Cost:* Two types where one existed. The split between "fetch data" (builder/service) and "transform data" (calculator) must be maintained by discipline.
- *Benefit:* Test coverage for the aggregation logic — most of the bugs would live here — is trivial to write. During this refactor, tests exposed that the `trainDuration` challenge type had a `targetValue: 90` (minutes) but the evaluator returned `0` or `1` (binary). `1 >= 90` is never true, so the challenge could *never complete*. Bug was pre-existing; tests found it.
- *Benefit:* Deterministic testing via injectable RNG. `ChallengeGenerator.GenerationContext` accepts a `randomSeed` parameter, so tests can verify "same seed → same output" and "different seeds → different outputs" without mocking system randomness.

**Alternatives considered.**
- **Keep logic on managers.** Managers stay closer to data, tests bootstrap more. Rejected; the aggregation logic is genuinely pure and benefits from the separation.
- **Free functions (no enum namespace).** Works but pollutes the top-level namespace. The enum-as-namespace pattern is idiomatic Swift.

---

## 4. Swift 6 strict concurrency, no opt-outs

**Context.** Swift 6 was released with opt-in strict concurrency checking. Many teams enable minimal checking and disable per-file where it's painful. This project was built greenfield on Swift 6.

**Decision.** Enable complete concurrency checking, treat it as the target. Every new type that crosses boundaries is `Sendable`. Every `@Observable` presenter is `@MainActor`. No `@unchecked Sendable` in code I wrote. Third-party manager classes from `SwiftfulThinking` packages are accepted as-is via `@retroactive` conformances only for protocol adoption, not to bypass `Sendable` checks.

Specific decisions within this:
- **Presenters are `@MainActor`-annotated classes** (not actors). SwiftUI views run on the main actor; pushing presenters off it would force unnecessary actor hops in the hottest path.
- **Services (Account/SessionLogging/MonthlyReport) are `@MainActor` structs.** Value semantics + main-actor isolation = no concurrency worries, no reference cycles.
- **Manager classes are `@Observable @MainActor`.** Same reasoning — they're consumed by views.
- **Alert callbacks in `SwiftfulRouting` use `@escaping @MainActor @Sendable () -> Void`.** This specific type is the one that lets a `@MainActor` presenter method satisfy the closure type without bridging. Learned the hard way.

**Tradeoffs.**
- *Cost:* Some existing patterns don't compile and need restructuring. Takes longer up-front.
- *Benefit:* Data race bugs that traditionally surface in production under load are caught at build time. Three force-unwrap / race conditions were prevented during development by the compiler refusing to let something through.

**Alternatives considered.**
- **Minimal checking + per-file disables.** Faster to write initially; accumulates technical debt. Rejected as a portfolio signal — the point is to demonstrate I can work in the strictest mode.
- **Use actors instead of `@MainActor` classes for services.** Actors add actor-hop overhead on every method call. For services consumed by `@MainActor` presenters, this is pure cost with no benefit. Main-actor isolation is correct.

---

## 5. Offline-first data, remote sync is optimization

**Context.** A training tracker is used in gyms — often with poor connectivity. The worst user experience would be: "Open app → wait for network → see empty state → give up."

**Decision.** Local persistence (SwiftData for collections, FileManager-backed JSON for documents) is the source of truth for UX. Every read goes to local; every write goes to local first, then queues a remote sync task. `ChallengeManager.currentChallenges`, `TechniqueManager.techniques`, `SessionManager.sessions` — all resolve synchronously from in-memory caches backed by local persistence.

Remote Firestore sync is additive: it merges remote-only records into local after login. Users never wait on the network to see their own data.

Explicit consequence: **monthly reports reflect whatever is locally available.** If a manager is still syncing, the report shows partial data. This is documented in `MonthlyReportBuilder.swift` as intentional — reports are historical (not live), so freshness < responsiveness. If a staleness banner is ever needed, the hook is `isDataStale` flags on contributing managers.

**Tradeoffs.**
- *Cost:* Eventual consistency. A session logged on device A might not appear on device B for several seconds. For a solo-user training tracker, this is acceptable.
- *Cost:* Local cache corruption (rare) would surface as "my data is gone." Mitigated by remote sync re-hydrating on login.
- *Benefit:* App opens instantly even offline. Users can log sessions on a plane. Dashboards render with real data in under a frame.

**Alternatives considered.**
- **Remote-first with local cache as fallback.** Standard mobile pattern, but introduces loading states everywhere and penalizes the common case (user has local data) for the rare case (first launch on a new device).
- **Remote-only, no cache.** Would be trivially simpler but fails the "poor gym wifi" scenario.

---

## Bonus: the trainDuration bug

The clearest demonstration of why this architecture pays for itself.

During the test-coverage pass, I wrote `ChallengeManagerDurationTests.longSessionCompletes()`:

```swift
@Test("A 90+ minute session completes the challenge")
func longSessionCompletes() {
    let (manager, _) = managerWithChallenge(type: .trainDuration, target: 90)
    let sessions = [weekSession(dayOffset: 0, duration: 5400)] // 90 minutes exactly
    let completed = manager.evaluate(...)
    #expect(completed.count == 1)
}
```

The test failed. The challenge refused to complete even with an exactly-90-minute session.

Digging in:
- `ChallengeGenerator.intensityCandidates()` produced: `targetValue: 90` (representing minutes)
- `ChallengeManager` evaluated: returned `1` if any session had `duration >= 90 minutes`, else `0`
- Completion check: `currentValue >= targetValue` → `1 >= 90` → **always false**

This challenge had shipped in production and could never complete. No user would have noticed — completion was silent, there was no error.

The fix was structural: `targetValue = 1` (binary completion), threshold minutes moved to `metadata` field. Evaluator reads threshold from metadata, defaults to 90 if missing. Progress text now correctly shows "0/1" or "1/1" instead of the nonsensical "1/90."

Tests for the fix live at `WazaUnitTests/ChallengeManagerTests.swift`. The bug and fix are referenced in `.claude/docs/improvement-plan.md`.
