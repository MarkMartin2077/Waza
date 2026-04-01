import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    private let interactor: TabBarInteractor

    private var unlockQueue: [AchievementId] = []
    var pendingUnlockAchievement: AchievementId?
    var pendingCheckIn: (gym: GymLocationModel, schedule: ClassScheduleModel?)?

    init(interactor: TabBarInteractor) {
        self.interactor = interactor
    }

    var beltAccentColor: Color {
        .wazaAccent
    }

    var lastUnlockedAchievement: AchievementId? {
        interactor.lastUnlockedAchievement
    }

    func onAchievementUnlocked(_ id: AchievementId) {
        interactor.consumeUnlockedAchievement()
        unlockQueue.append(id)
        // If nothing is currently showing, present the first in queue
        guard pendingUnlockAchievement == nil else { return }
        showNextAchievement()
    }

    func onAchievementDismissed() {
        interactor.trackEvent(event: Event.achievementDismissed)
        withAnimation(.easeOut(duration: 0.2)) {
            pendingUnlockAchievement = nil
        }
        // Show next queued achievement after a short delay
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            showNextAchievement()
        }
    }

    private func showNextAchievement() {
        guard pendingUnlockAchievement == nil, !unlockQueue.isEmpty else { return }
        let id = unlockQueue.removeFirst()
        interactor.trackEvent(event: Event.achievementDisplayed(id: id.rawValue))
        Task { @MainActor in
            // Wait for any sheet dismiss animation to finish
            try? await Task.sleep(nanoseconds: 600_000_000)
            withAnimation(.easeIn(duration: 0.2)) {
                pendingUnlockAchievement = id
            }
            interactor.playHaptic(option: .heavy)
            try? await Task.sleep(nanoseconds: 150_000_000)
            interactor.playHaptic(option: .heavy)
            try? await Task.sleep(nanoseconds: 250_000_000)
            interactor.playHaptic(option: .success)
        }
    }

    func onGymArrival(gymId: String) {
        interactor.trackEvent(event: Event.gymArrivalDetected(gymId: gymId))
        guard pendingCheckIn == nil else { return }
        guard let gym = interactor.gyms.first(where: { $0.gymId == gymId }) else { return }
        let schedule = interactor.closestSchedule(forGymId: gymId, at: Date())
        pendingCheckIn = (gym, schedule)
    }

    func onCheckInDismissed() {
        interactor.trackEvent(event: Event.checkInPromptDismissed)
        pendingCheckIn = nil
    }
}

extension TabBarPresenter {
    enum Event: LoggableEvent {
        case achievementDisplayed(id: String)
        case achievementDismissed
        case gymArrivalDetected(gymId: String)
        case checkInPromptDismissed

        var eventName: String {
            switch self {
            case .achievementDisplayed: return "TabBar_Achievement_Displayed"
            case .achievementDismissed: return "TabBar_Achievement_Dismissed"
            case .gymArrivalDetected:   return "TabBar_GymArrival_Detected"
            case .checkInPromptDismissed: return "TabBar_CheckIn_Dismissed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .achievementDisplayed(id: let id):
                return ["achievement_id": id]
            case .gymArrivalDetected(gymId: let gymId):
                return ["gym_id": gymId]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
