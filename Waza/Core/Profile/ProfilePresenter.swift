import SwiftUI

@Observable
@MainActor
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter

    private(set) var currentBelt: BeltRecordModel?
    private(set) var beltHistory: [BeltRecordModel] = []
    private(set) var sessionStats: SessionStats = .empty
    private(set) var earnedAchievements: [AchievementEarnedModel] = []
    private(set) var isPremium: Bool = false
    private(set) var userName: String = ""

    var showAddPromotionSheet: Bool = false
    var errorMessage: String?

    // New promotion form
    var newBelt: BJJBelt = .white
    var newStripes: Int = 0
    var newPromotionDate: Date = Date()
    var newAcademy: String = ""
    var newPromotionNotes: String = ""

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
        currentBelt = interactor.currentBelt
        beltHistory = interactor.beltHistory
        sessionStats = interactor.sessionStats
        earnedAchievements = interactor.earnedAchievements
        isPremium = interactor.isPremium
        userName = interactor.currentUser?.commonNameCalculated ?? interactor.currentUser?.displayName ?? "Grappler"
    }

    func onSettingsButtonPressed() {
        interactor.trackEvent(event: Event.settingsPressed)
        router.showSettingsView()
    }

    func onAddPromotionTapped() {
        interactor.trackEvent(event: Event.addPromotionTapped)
        resetPromotionForm()
        showAddPromotionSheet = true
    }

    func onSavePromotion() {
        interactor.trackEvent(event: Event.savePromotionTapped)
        do {
            _ = try interactor.addBeltPromotion(
                belt: newBelt,
                stripes: newStripes,
                date: newPromotionDate,
                academy: newAcademy.isEmpty ? nil : newAcademy,
                notes: newPromotionNotes.isEmpty ? nil : newPromotionNotes
            )
            showAddPromotionSheet = false
            loadData()
            interactor.playHaptic(option: .success)
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            errorMessage = error.localizedDescription
        }
    }

    func onCancelPromotion() {
        showAddPromotionSheet = false
    }

    private func resetPromotionForm() {
        newBelt = interactor.currentBeltEnum.nextBelt ?? .white
        newStripes = 0
        newPromotionDate = Date()
        newAcademy = ""
        newPromotionNotes = ""
    }

    var beltDisplayName: String {
        currentBelt?.displayTitle ?? interactor.currentBeltEnum.displayName
    }

    var totalTrainingHoursText: String {
        String(format: "%.0f", sessionStats.totalTrainingHours)
    }
}

extension ProfilePresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: ProfileDelegate)
        case onDisappear(delegate: ProfileDelegate)
        case settingsPressed
        case addPromotionTapped
        case savePromotionTapped
        case saveFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "ProfileView_Appear"
            case .onDisappear:          return "ProfileView_Disappear"
            case .settingsPressed:      return "ProfileView_Settings_Pressed"
            case .addPromotionTapped:   return "ProfileView_AddPromotion_Tap"
            case .savePromotionTapped:  return "ProfileView_SavePromotion_Tap"
            case .saveFail:             return "ProfileView_Save_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .saveFail(error: let error):
                return error.eventParameters
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
