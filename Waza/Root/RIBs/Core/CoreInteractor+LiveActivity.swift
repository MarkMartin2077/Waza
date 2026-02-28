import Foundation

extension CoreInteractor {

    func startTrainingLiveActivity(
        sessionTypeDisplayName: String,
        gymName: String?,
        beltAccentColorHex: String
    ) {
        liveActivityManager.startTraining(
            sessionTypeDisplayName: sessionTypeDisplayName,
            gymName: gymName,
            beltAccentColorHex: beltAccentColorHex
        )
    }

    func endTrainingLiveActivity() async {
        await liveActivityManager.endTraining()
    }
}
