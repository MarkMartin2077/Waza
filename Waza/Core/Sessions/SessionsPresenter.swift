import SwiftUI

@Observable
@MainActor
class SessionsPresenter {
    private let router: any SessionsRouter
    private let interactor: any SessionsInteractor

    private(set) var nextUpcomingClass: (ClassScheduleModel, GymLocationModel)?

    // MARK: - Search & Filter State

    var searchText: String = ""
    var selectedSessionTypes: Set<SessionType> = []
    var selectedAcademy: String?
    var selectedMood: Int?

    init(router: any SessionsRouter, interactor: any SessionsInteractor) {
        self.router = router
        self.interactor = interactor
    }

    // MARK: - Computed Properties

    var beltAccentColor: Color {
        .wazaAccent
    }

    var hasActiveFilters: Bool {
        !selectedSessionTypes.isEmpty || selectedAcademy != nil || selectedMood != nil
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var availableAcademies: [String] {
        let academies = interactor.allSessions.compactMap(\.academy).filter { !$0.isEmpty }
        return Array(Set(academies)).sorted()
    }

    var filteredSessions: [BJJSessionModel] {
        var result = interactor.allSessions

        // Search filter
        if isSearching {
            let query = searchText.lowercased()
            result = result.filter { session in
                session.focusAreas.contains { $0.lowercased().contains(query) }
                || session.notes?.lowercased().contains(query) == true
                || session.whatWorkedWell?.lowercased().contains(query) == true
                || session.needsImprovement?.lowercased().contains(query) == true
                || session.keyInsights?.lowercased().contains(query) == true
                || session.academy?.lowercased().contains(query) == true
                || session.instructor?.lowercased().contains(query) == true
                || session.sessionType.displayName.lowercased().contains(query) == true
            }
        }

        // Session type filter
        if !selectedSessionTypes.isEmpty {
            result = result.filter { selectedSessionTypes.contains($0.sessionType) }
        }

        // Academy filter
        if let selectedAcademy {
            result = result.filter { $0.academy == selectedAcademy }
        }

        // Mood filter (matches either pre or post mood)
        if let selectedMood {
            result = result.filter { $0.preSessionMood == selectedMood || $0.postSessionMood == selectedMood }
        }

        return result
    }

    var groupedSessions: [SessionGroup] {
        let filtered = filteredSessions
        guard !filtered.isEmpty else { return [] }

        let calendar = Calendar.current
        let titleFormatter = DateFormatter()
        titleFormatter.dateFormat = "MMMM yyyy"

        var dict: [String: [BJJSessionModel]] = [:]
        var titles: [String: String] = [:]

        for session in filtered {
            let comps = calendar.dateComponents([.year, .month], from: session.date)
            let key = String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
            dict[key, default: []].append(session)
            if titles[key] == nil {
                titles[key] = titleFormatter.string(from: session.date)
            }
        }

        return dict.keys.sorted(by: >).map { key in
            SessionGroup(id: key, title: titles[key]!, sessions: dict[key]!)
        }
    }

    var filteredCount: Int {
        filteredSessions.count
    }

    var totalCount: Int {
        interactor.allSessions.count
    }

    // MARK: - Filter Labels

    var sessionTypeFilterLabel: String {
        if selectedSessionTypes.isEmpty {
            return "Type"
        } else if selectedSessionTypes.count == 1, let type = selectedSessionTypes.first {
            return type.displayName
        } else {
            return "\(selectedSessionTypes.count) Types"
        }
    }

    var academyFilterLabel: String {
        selectedAcademy ?? "Gym"
    }

    var moodFilterLabel: String {
        if let selectedMood {
            return Mood.emoji(for: selectedMood)
        }
        return "Mood"
    }

    // MARK: - Actions

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadData()
    }

    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        router.showSessionDetailView(session: session)
    }

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logTapped)
        router.showSessionEntryView(onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    func onDeleteSwipeTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.deleteSwipeTapped)
        router.showAlert(.alert, title: "Delete Session?", subtitle: "This action cannot be undone.") {
            AnyView(
                Group {
                    Button("Delete", role: .destructive) { [weak self] in
                        self?.onDeleteConfirmed(session)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
        }
    }

    func onDeleteConfirmed(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.deleteConfirmed)
        do {
            try interactor.deleteSession(session)
        } catch {
            interactor.trackEvent(event: Event.deleteFailed(error: error))
        }
    }

    func onCheckInTapped(gym: GymLocationModel, schedule: ClassScheduleModel?) {
        interactor.trackEvent(event: Event.checkInTapped)
        router.showCheckInView(gym: gym, schedule: schedule, checkInMethod: .manual, onDismiss: { [weak self] in
            self?.loadData()
        })
    }

    // MARK: - Filter Actions

    func onSessionTypeToggled(_ type: SessionType) {
        if selectedSessionTypes.contains(type) {
            selectedSessionTypes.remove(type)
        } else {
            selectedSessionTypes.insert(type)
        }
        interactor.trackEvent(event: Event.filterTypeChanged(types: selectedSessionTypes.map(\.displayName)))
    }

    func onAcademySelected(_ academy: String?) {
        selectedAcademy = academy
        interactor.trackEvent(event: Event.filterAcademyChanged(academy: academy))
    }

    func onMoodSelected(_ mood: Int?) {
        selectedMood = mood
        interactor.trackEvent(event: Event.filterMoodChanged(mood: mood))
    }

    func onClearFilters() {
        selectedSessionTypes = []
        selectedAcademy = nil
        selectedMood = nil
        interactor.trackEvent(event: Event.filterCleared)
    }

    // MARK: - Private

    private func loadData() {
        nextUpcomingClass = interactor.nextUpcomingClass
        updateWidgets()
    }

    private func updateWidgets() {
        let streak = interactor.currentStreakData.currentStreak ?? 0
        let stats = interactor.sessionStats
        interactor.updateWidgetData(WazaWidgetData(
            streakCount: streak,
            accentColorHex: Color.wazaAccentHex,
            beltDisplayName: interactor.currentBeltEnum.displayName,
            sessionsThisWeek: stats.thisWeekSessions,
            nextClassTypeDisplayName: nextUpcomingClass?.0.sessionType.displayName,
            nextClassGymName: nextUpcomingClass?.1.name,
            nextClassDayOfWeek: nextUpcomingClass?.0.dayOfWeek,
            nextClassStartHour: nextUpcomingClass?.0.startHour,
            nextClassStartMinute: nextUpcomingClass?.0.startMinute
        ))
    }

}

// MARK: - Session Group

struct SessionGroup: Identifiable {
    let id: String
    let title: String
    let sessions: [BJJSessionModel]
}

// MARK: - Events

extension SessionsPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case sessionTapped
        case logTapped
        case checkInTapped
        case deleteSwipeTapped
        case deleteConfirmed
        case deleteFailed(error: Error)
        case filterTypeChanged(types: [String])
        case filterAcademyChanged(academy: String?)
        case filterMoodChanged(mood: Int?)
        case filterCleared

        var eventName: String {
            switch self {
            case .onAppear:              return "SessionsView_Appear"
            case .sessionTapped:         return "SessionsView_SessionTap"
            case .logTapped:             return "SessionsView_LogTap"
            case .checkInTapped:         return "SessionsView_CheckIn_Tap"
            case .deleteSwipeTapped:     return "SessionsView_Delete_Swipe_Tap"
            case .deleteConfirmed:       return "SessionsView_Delete_Confirm"
            case .deleteFailed:          return "SessionsView_Delete_Fail"
            case .filterTypeChanged:     return "SessionsView_Filter_Type"
            case .filterAcademyChanged:  return "SessionsView_Filter_Academy"
            case .filterMoodChanged:     return "SessionsView_Filter_Mood"
            case .filterCleared:         return "SessionsView_Filter_Clear"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .deleteFailed(error: let error):
                return error.eventParameters
            case .filterTypeChanged(types: let types):
                return ["types": types.joined(separator: ",")]
            case .filterAcademyChanged(academy: let academy):
                return ["academy": academy ?? "none"]
            case .filterMoodChanged(mood: let mood):
                return ["mood": mood ?? 0]
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .deleteFailed: return .severe
            default: return .analytic
            }
        }
    }
}
