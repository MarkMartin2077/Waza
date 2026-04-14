---
name: currentUserName already on CoreInteractor
description: currentUserName is defined in CoreInteractor+ClassSchedule.swift — never redefine it in other BJJ extension files
type: feedback
---

`currentUserName` is already computed on `CoreInteractor` via `CoreInteractor+ClassSchedule.swift`:
```swift
var currentUserName: String {
    currentUser?.commonNameCalculated ?? currentUser?.displayName ?? "Grappler"
}
```

**Why:** Duplicate computed properties on the same type cause a compile error.

**How to apply:** When a new interactor protocol declares `currentUserName`, the `extension CoreInteractor: XxxInteractor { }` conformance automatically satisfies it — no need to re-implement.
