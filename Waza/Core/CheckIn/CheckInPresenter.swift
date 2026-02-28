import SwiftUI

@Observable
@MainActor
class CheckInPresenter {
    private let interactor: CheckInInteractor
    private let router: CheckInRouter
    let delegate: CheckInDelegate

    var selectedMood: Int = 0       // 0 = unselected, 1-5
    var isConfirmed: Bool = false
    var aiMessage: String = ""
    var isStreamingAI: Bool = false
    var errorMessage: String?
    private(set) var checkedInRecord: ClassAttendanceModel?

    init(interactor: CheckInInteractor, router: CheckInRouter, delegate: CheckInDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onMoodSelected(_ rating: Int) {
        interactor.trackEvent(event: Event.moodSelected(rating: rating))
        selectedMood = selectedMood == rating ? 0 : rating
    }

    func onConfirmTapped() {
        interactor.trackEvent(event: Event.confirmTapped)
        do {
            let record = try interactor.checkIn(
                gymId: delegate.gym.gymId,
                scheduleId: delegate.matchedSchedule?.scheduleId,
                method: delegate.checkInMethod,
                moodRating: selectedMood > 0 ? selectedMood : nil
            )
            checkedInRecord = record
            isConfirmed = true
            interactor.trackEvent(event: Event.checkInSuccess)
            interactor.playHaptic(option: .success)
            streamAIEncouragement()
            delegate.onCheckedIn?(record)
        } catch {
            interactor.trackEvent(event: Event.checkInFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logSessionTapped)
        router.showSessionEntryView { [weak self] in
            self?.router.dismissScreen()
        }
    }

    func onDismissTapped() {
        interactor.trackEvent(event: Event.dismissTapped)
        router.dismissScreen()
    }

    var gymName: String { delegate.gym.name }
    var scheduleName: String? { delegate.matchedSchedule?.name }

    // MARK: - AI

    private func streamAIEncouragement() {
        let streak = interactor.currentStreakData.currentStreak ?? 0
        let classesThisWeek = interactor.weeklyAttendanceCount(weekOf: Date())
        let belt = interactor.currentBeltEnum
        let totalAttendance = interactor.classAttendance.count
        let weeklyTarget = 3
        let userName = interactor.currentUserName

        isStreamingAI = true
        aiMessage = ""

        let stream = interactor.generateCheckInEncouragement(
            userName: userName,
            streakCount: streak,
            classesThisWeek: classesThisWeek,
            weeklyTarget: weeklyTarget,
            belt: belt,
            totalAttendance: totalAttendance
        )

        Task {
            do {
                for try await partial in stream {
                    aiMessage = partial
                }
                if let record = checkedInRecord, !aiMessage.isEmpty {
                    var updated = record
                    updated.aiEncouragement = aiMessage
                    try? interactor.updateAttendance(updated)
                }
            } catch {
                interactor.trackEvent(event: Event.aiEncouragementFail(error: error))
            }
            isStreamingAI = false
        }
    }
}

extension CheckInPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case moodSelected(rating: Int)
        case confirmTapped
        case checkInSuccess
        case logSessionTapped
        case dismissTapped
        case checkInFail(error: Error)
        case aiEncouragementFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "CheckInView_Appear"
            case .moodSelected:         return "CheckInView_Mood_Select"
            case .confirmTapped:        return "CheckInView_Confirm_Tap"
            case .checkInSuccess:       return "CheckInView_CheckIn_Success"
            case .logSessionTapped:     return "CheckInView_LogSession_Tap"
            case .dismissTapped:        return "CheckInView_Dismiss_Tap"
            case .checkInFail:          return "CheckInView_CheckIn_Fail"
            case .aiEncouragementFail:  return "CheckInView_AIEncouragement_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .moodSelected(rating: let rating): return ["mood_rating": rating]
            case .checkInFail(error: let error): return error.eventParameters
            case .aiEncouragementFail(error: let error): return error.eventParameters
            default: return nil
            }
        }

        var type: LogType {
            switch self {
            case .checkInFail: return .severe
            case .aiEncouragementFail: return .warning
            default: return .analytic
            }
        }
    }
}

struct CheckInDelegate {
    let gym: GymLocationModel
    var matchedSchedule: ClassScheduleModel?
    var checkInMethod: CheckInMethod = .manual
    var onCheckedIn: ((ClassAttendanceModel) -> Void)?
}
