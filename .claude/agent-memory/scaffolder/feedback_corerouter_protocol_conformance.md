---
name: CoreRouter conformance pattern — implementations in any extension file satisfy all protocols
description: A showXxx() method on CoreRouter defined in any extension file satisfies every router protocol that declares that method signature
type: feedback
---

`CoreRouter` extension methods are global — a `showMonthlyReportView()` defined in `MonthlyReportView.swift`'s `extension CoreRouter` automatically satisfies both `MonthlyReportRouter` and `ProfileRouter` (and any other protocol that declares `func showMonthlyReportView()`).

**Why:** Swift resolves protocol conformance across all extension files for the same type. You never need to re-implement the same method — just declare the method signature in the new router protocol.

**How to apply:** When a screen like Profile wants to navigate to Monthly Report, add `func showMonthlyReportView()` to `ProfileRouter` protocol. The existing CoreRouter implementation in MonthlyReportView.swift already satisfies it. Never create a duplicate implementation.
