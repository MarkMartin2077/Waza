#if canImport(ActivityKit)
@preconcurrency import ActivityKit
#endif
import Foundation

@MainActor
@Observable
final class LiveActivityManager {

    #if canImport(ActivityKit)
    private var currentActivity: Activity<TrainingTimerAttributes>?

    var hasActiveTraining: Bool {
        currentActivity?.activityState == .active
    }
    #endif

    func startTraining(
        sessionTypeDisplayName: String,
        gymName: String?,
        beltAccentColorHex: String
    ) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TrainingTimerAttributes(
            sessionTypeDisplayName: sessionTypeDisplayName,
            gymName: gymName,
            beltAccentColorHex: beltAccentColorHex,
            startDate: Date()
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(
                    state: TrainingTimerAttributes.ContentState(),
                    staleDate: Date().addingTimeInterval(4 * 3600)
                ),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            // Live Activity is an enhancement — failure is non-critical
        }
        #endif
    }

    func endTraining() async {
        #if canImport(ActivityKit)
        guard let activity = currentActivity else { return }
        currentActivity = nil
        await activity.end(nil, dismissalPolicy: .immediate)
        #endif
    }
}
