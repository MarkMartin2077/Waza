import SwiftUI

@Observable
@MainActor
class SessionEntryPresenter {
    private let interactor: SessionEntryInteractor
    private let router: SessionEntryRouter
    let delegate: SessionEntryDelegate

    // Form fields
    var date: Date = Date()
    var sessionType: SessionType = .gi
    var durationMinutes: Int = 90
    var academy: String = ""
    var instructor: String = ""
    var notes: String = ""
    var preSessionMood: Int = 3
    var postSessionMood: Int = 3
    var roundsCount: Int = 0
    var whatWorkedWell: String = ""
    var needsImprovement: String = ""
    var keyInsights: String = ""
    var showMoodSection: Bool = false

    // Focus Areas
    var selectedFocusAreas: Set<String> = []
    var customFocusAreaText: String = ""

    static let presetFocusAreas = ["Guard", "Passing", "Takedowns", "Sweeps", "Submissions", "Escapes"]

    // Gym Selection
    var savedGyms: [GymLocationModel] = []
    var selectedGymId: String?
    var isCustomAcademy: Bool = false

    var isLoading: Bool = false

    init(interactor: SessionEntryInteractor, router: SessionEntryRouter, delegate: SessionEntryDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        savedGyms = interactor.gyms
        if savedGyms.count == 1 {
            selectedGymId = savedGyms.first?.gymId
            academy = savedGyms.first?.name ?? ""
        }
    }

    // MARK: - Focus Areas

    func onFocusAreaToggled(_ area: String) {
        interactor.trackEvent(event: Event.focusAreaToggled(area: area))
        interactor.playHaptic(option: .selection)
        if selectedFocusAreas.contains(area) {
            selectedFocusAreas.remove(area)
        } else {
            selectedFocusAreas.insert(area)
        }
    }

    func onAddCustomFocusArea() {
        let trimmed = customFocusAreaText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let normalized = trimmed.capitalized
        guard !selectedFocusAreas.contains(where: { $0.caseInsensitiveCompare(normalized) == .orderedSame }) else {
            customFocusAreaText = ""
            return
        }
        interactor.trackEvent(event: Event.customFocusAreaAdded(area: normalized))
        interactor.playHaptic(option: .selection)
        selectedFocusAreas.insert(normalized)
        customFocusAreaText = ""
    }

    // MARK: - Gym Selection

    func onGymSelected(_ gymId: String?) {
        interactor.trackEvent(event: Event.gymSelected(gymId: gymId))
        interactor.playHaptic(option: .selection)
        if let gymId, let gym = savedGyms.first(where: { $0.gymId == gymId }) {
            selectedGymId = gymId
            academy = gym.name
            isCustomAcademy = false
        } else {
            selectedGymId = nil
            academy = ""
            isCustomAcademy = true
        }
    }

    func onSessionTypeSelected(_ type: SessionType) {
        interactor.trackEvent(event: Event.sessionTypeSelected(type: type))
        interactor.playHaptic(option: .selection)
        sessionType = type
    }

    // MARK: - Duration

    func onDurationIncreased() {
        guard durationMinutes < 300 else { return }
        durationMinutes += 15
        interactor.trackEvent(event: Event.durationChanged(minutes: durationMinutes))
        interactor.playHaptic(option: .selection)
    }

    func onDurationDecreased() {
        guard durationMinutes > 15 else { return }
        durationMinutes -= 15
        interactor.trackEvent(event: Event.durationChanged(minutes: durationMinutes))
        interactor.playHaptic(option: .selection)
    }

    func onSectionHeaderTapped() {
        interactor.trackEvent(event: Event.sectionHeaderTapped)
        interactor.playHaptic(option: .selection)
    }

    func onMoodSelected(isBefore: Bool, rating: Int) {
        interactor.trackEvent(event: Event.moodSelected(isBefore: isBefore, rating: rating))
        interactor.playHaptic(option: .selection)
        if isBefore {
            preSessionMood = rating
        } else {
            postSessionMood = rating
        }
    }

    func onSavePressed() {
        interactor.trackEvent(event: Event.saveTapped)
        Task {
            await saveSession()
        }
    }

    func onCancelPressed() {
        interactor.trackEvent(event: Event.cancelTapped)
        router.dismissScreen()
    }

    private func saveSession() async {
        isLoading = true

        do {
            let params = SessionEntryParams(
                date: date,
                duration: TimeInterval(durationMinutes * 60),
                sessionType: sessionType,
                academy: academy.isEmpty ? nil : academy,
                instructor: instructor.isEmpty ? nil : instructor,
                focusAreas: Array(selectedFocusAreas),
                notes: notes.isEmpty ? nil : notes,
                preSessionMood: showMoodSection ? preSessionMood : nil,
                postSessionMood: showMoodSection ? postSessionMood : nil,
                roundsCount: roundsCount,
                whatWorkedWell: whatWorkedWell.isEmpty ? nil : whatWorkedWell,
                needsImprovement: needsImprovement.isEmpty ? nil : needsImprovement,
                keyInsights: keyInsights.isEmpty ? nil : keyInsights
            )
            let session = try await interactor.logSessionWithGamification(params)
            interactor.trackEvent(event: Event.saveSuccess(sessionId: session.id))
            interactor.playHaptic(option: .success)
            delegate.onSessionSaved?(session)
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }

        isLoading = false
    }

    var beltAccentColor: Color {
        .wazaAccent
    }

    var durationText: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}

extension SessionEntryPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case saveTapped
        case saveSuccess(sessionId: String)
        case saveFail(error: Error)
        case cancelTapped
        case sessionTypeSelected(type: SessionType)
        case focusAreaToggled(area: String)
        case customFocusAreaAdded(area: String)
        case gymSelected(gymId: String?)
        case durationChanged(minutes: Int)
        case sectionHeaderTapped
        case moodSelected(isBefore: Bool, rating: Int)

        var eventName: String {
            switch self {
            case .onAppear:               return "SessionEntryView_Appear"
            case .saveTapped:             return "SessionEntryView_Save_Tap"
            case .saveSuccess:            return "SessionEntryView_Save_Success"
            case .saveFail:               return "SessionEntryView_Save_Fail"
            case .cancelTapped:           return "SessionEntryView_Cancel_Tap"
            case .sessionTypeSelected:    return "SessionEntryView_SessionType_Select"
            case .focusAreaToggled:       return "SessionEntryView_FocusArea_Toggle"
            case .customFocusAreaAdded:   return "SessionEntryView_FocusArea_Custom_Add"
            case .gymSelected:            return "SessionEntryView_Gym_Select"
            case .durationChanged:        return "SessionEntryView_Duration_Change"
            case .sectionHeaderTapped:    return "SessionEntryView_SectionHeader_Tap"
            case .moodSelected:           return "SessionEntryView_Mood_Select"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .saveSuccess(sessionId: let sessionId):
                return ["session_id": sessionId]
            case .saveFail(error: let error):
                return error.eventParameters
            case .sessionTypeSelected(type: let type):
                return ["session_type": type.rawValue]
            case .focusAreaToggled(area: let area), .customFocusAreaAdded(area: let area):
                return ["focus_area": area]
            case .gymSelected(gymId: let gymId):
                return ["gym_id": gymId ?? "custom"]
            case .durationChanged(minutes: let minutes):
                return ["duration_minutes": minutes]
            case .moodSelected(isBefore: let isBefore, rating: let rating):
                return ["is_before": isBefore, "mood_rating": rating]
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .saveFail: return .severe
            default: return .analytic
            }
        }
    }
}

struct SessionEntryDelegate {
    var onSessionSaved: ((BJJSessionModel) -> Void)?
    var eventParameters: [String: Any]? { nil }
}
