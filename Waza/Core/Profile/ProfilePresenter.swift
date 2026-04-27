import SwiftUI

@Observable
@MainActor
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter

    private(set) var sessionStats: SessionStats = .empty
    private(set) var isPremium: Bool = false
    private(set) var userName: String = ""
    private(set) var streakCount: Int = 0
    private(set) var xpLevelInfo: XPLevelInfo = XPLevelSystem.levelInfo(forXP: 0)
    private(set) var streakTier: StreakTier = .none
    private(set) var fireRoundExpiresAt: Date?
    private(set) var perfectWeekActive: Bool = false

    init(interactor: ProfileInteractor, router: ProfileRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: ProfileDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        loadData()
    }

    func onViewDisappear(delegate: ProfileDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func loadData() {
        sessionStats = interactor.sessionStats
        isPremium = interactor.isPremium
        userName = interactor.currentUser?.commonNameCalculated ?? interactor.currentUser?.displayName ?? "Grappler"
        streakCount = interactor.currentStreakData.currentStreak ?? 0
        let totalXP = interactor.currentExperiencePointsData.pointsAllTime ?? 0
        xpLevelInfo = XPLevelSystem.levelInfo(forXP: totalXP)
        streakTier = StreakTier.tier(forDays: streakCount)
        fireRoundExpiresAt = XPMultiplierCalculator.fireRoundExpiresAt()
        perfectWeekActive = interactor.sessionStats.thisWeekSessions >= XPMultiplierCalculator.perfectWeekTarget
    }

    // MARK: - Computed display values

    var beltAccentColor: Color {
        .wazaAccent
    }

    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }

    var shareCardImage: UIImage? {
        let streakDays = streakCount
        let tier = streakTier
        guard streakDays >= 3 else { return nil }
        return ShareCardRenderer.render(
            card: ShareCardView(
                cardType: .streakFlex(streakCount: streakDays, tier: tier),
                userName: userName,
                accentColor: .wazaAccent
            )
        )
    }

    var totalTrainingHoursText: String {
        String(format: "%.0f", sessionStats.totalTrainingHours)
    }

    var avatarInitials: String {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "?" }
        let parts = trimmed.split(separator: " ")
        if parts.count >= 2,
           let first = parts.first?.first,
           let second = parts.dropFirst().first(where: { !$0.isEmpty })?.first {
            return String([first, second]).uppercased()
        }
        return String(trimmed.prefix(1)).uppercased()
    }

}

extension ProfilePresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: ProfileDelegate)
        case onDisappear(delegate: ProfileDelegate)
        case settingsPressed

        var eventName: String {
            switch self {
            case .onAppear:        return "ProfileView_Appear"
            case .onDisappear:     return "ProfileView_Disappear"
            case .settingsPressed: return "ProfileView_Settings_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            .analytic
        }
    }

}
