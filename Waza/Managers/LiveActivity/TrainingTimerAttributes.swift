import Foundation

// MARK: - Shared Activity Attributes
// This struct is intentionally duplicated in WazaWidgets/TrainingTimerLiveActivity.swift.
// Both targets must stay in sync — same field names, same CodingKeys.

#if canImport(ActivityKit)
import ActivityKit

struct TrainingTimerAttributes: ActivityAttributes {

    // Dynamic state — updated via Activity.update() (empty: timer is fully driven by startDate)
    struct ContentState: Codable, Hashable { }

    // Static — set at start, never changes during the activity
    let sessionTypeDisplayName: String
    let gymName: String?
    let beltAccentColorHex: String
    let startDate: Date
}
#endif
