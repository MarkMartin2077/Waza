//
//  SettingsPresenter.swift
//  
//
//  
//
import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class SettingsPresenter {
    
    private let interactor: SettingsInteractor
    private let router: SettingsRouter

    private(set) var isAnonymousUser: Bool = false

    var colorSchemeIndex: Int = UserDefaults.standard.integer(forKey: Constants.colorSchemeStorageKey) {
        didSet {
            UserDefaults.standard.set(colorSchemeIndex, forKey: Constants.colorSchemeStorageKey)
            interactor.trackEvent(event: Event.colorSchemeChanged(index: colorSchemeIndex))
        }
    }

    var resolvedColorScheme: ColorScheme? {
        switch colorSchemeIndex {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    init(interactor: SettingsInteractor, router: SettingsRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var beltAccentColor: Color {
        .wazaAccent
    }

    var userName: String {
        interactor.currentUserName
    }

    var userEmail: String? {
        let email = interactor.auth?.email
        return (email?.isEmpty == false) ? email : nil
    }

    var authProviderLabel: String? {
        guard let providers = interactor.auth?.authProviders else { return nil }
        if providers.contains(.apple) { return "Apple" }
        if providers.contains(.google) { return "Google" }
        return nil
    }

    var authProviderIcon: String? {
        guard let providers = interactor.auth?.authProviders else { return nil }
        if providers.contains(.apple) { return "apple.logo" }
        if providers.contains(.google) { return "g.circle.fill" }
        return nil
    }

    var userInitial: String {
        let trimmed = userName.trimmingCharacters(in: .whitespaces)
        return String(trimmed.first ?? "W").uppercased()
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        setAnonymousAccountStatus()
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }
    
    func setAnonymousAccountStatus() {
        isAnonymousUser = interactor.auth?.isAnonymous == true
    }
    
    func onContactUsPressed() {
        interactor.trackEvent(event: Event.contactUsPressed)
        let email = "WazaBJJApp@gmail.com"
        let emailString = "mailto:\(email)"

        guard let url = URL(string: emailString) else {
            return
        }

        router.openURL(url)
    }
    
    func onSignOutPressed() {
        interactor.trackEvent(event: Event.signOutStart)
        
        Task {
            do {
                try await interactor.signOut()
                interactor.trackEvent(event: Event.signOutSuccess)
                await dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.signOutFail(error: error))
            }
        }
    }
    
    private func dismissScreen() async {
        router.dismissScreen()
        try? await Task.sleep(for: .seconds(1))
        router.switchToOnboardingModule()
    }
        
    func onDeleteAccountPressed() {
        interactor.trackEvent(event: Event.deleteAccountStart)

        router.showAlert(
            .alert,
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server forever.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive) {
                        self.showDeleteAccountReauthAlert()
                    }
                )
            }
        )
    }
    
    private func showDeleteAccountReauthAlert() {
        router.showAlert(
            .alert,
            title: "Reauthentication Required",
            subtitle: "As a safety precaution in order to delete your account, you must first sign again.",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive) {
                        self.onDeleteAccountConfirmed()
                    }
                )
            }
        )
    }
    
    private func onDeleteAccountConfirmed() {
        interactor.trackEvent(event: Event.deleteAccountStartConfirm)

        Task {
            do {
                try await interactor.deleteAccount()
                interactor.trackEvent(event: Event.deleteAccountSuccess)
                await dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.deleteAccountFail(error: error))
            }
        }
    }
    
    func onCreateAccountPressed() {
        interactor.trackEvent(event: Event.createAccountPressed)

        let delegate = CreateAccountDelegate(
            title: "Save your journey",
            subtitle: "Back up your sessions and sync across every device.",
            kanji: "守"
        )
        router.showCreateAccountView(delegate: delegate, onDismiss: {
            self.setAnonymousAccountStatus()
        })
    }

    func onRateAppPressed() {
        interactor.trackEvent(event: Event.rateAppPressed)

        func onEnjoyingAppYesPressed() {
            interactor.trackEvent(event: Event.rateAppYesPressed)
            router.dismissModal()
            AppStoreRatingsHelper.requestRatingsReview()
        }

        func onEnjoyingAppNoPressed() {
            interactor.trackEvent(event: Event.rateAppNoPressed)
            router.dismissModal()
        }

        router.showRatingsModal(
            onYesPressed: onEnjoyingAppYesPressed,
            onNoPressed: onEnjoyingAppNoPressed
        )
    }

    func onShareAppPressed() {
        interactor.trackEvent(event: Event.shareAppPressed)
    }

    func onNotificationsSettingsPressed() {
        interactor.trackEvent(event: Event.notificationsSettingsPressed)
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        router.openURL(url)
    }

}

extension SettingsPresenter {
    
    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case signOutStart
        case signOutSuccess
        case signOutFail(error: Error)
        case deleteAccountStart
        case deleteAccountStartConfirm
        case deleteAccountSuccess
        case deleteAccountFail(error: Error)
        case createAccountPressed
        case contactUsPressed
        case colorSchemeChanged(index: Int)
        case rateAppPressed
        case rateAppYesPressed
        case rateAppNoPressed
        case shareAppPressed
        case notificationsSettingsPressed

        var eventName: String {
            switch self {
            case .onAppear:                       return "SettingsView_Appear"
            case .onDisappear:                    return "SettingsView_Disappear"
            case .signOutStart:                   return "SettingsView_SignOut_Start"
            case .signOutSuccess:                 return "SettingsView_SignOut_Success"
            case .signOutFail:                    return "SettingsView_SignOut_Fail"
            case .deleteAccountStart:             return "SettingsView_DeleteAccount_Start"
            case .deleteAccountStartConfirm:      return "SettingsView_DeleteAccount_StartConfirm"
            case .deleteAccountSuccess:           return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:              return "SettingsView_DeleteAccount_Fail"
            case .createAccountPressed:           return "SettingsView_CreateAccount_Pressed"
            case .contactUsPressed:               return "SettingsView_ContactUs_Pressed"
            case .colorSchemeChanged:             return "SettingsView_ColorScheme_Changed"
            case .rateAppPressed:                 return "SettingsView_RateApp_Pressed"
            case .rateAppYesPressed:              return "SettingsView_RateApp_Yes_Pressed"
            case .rateAppNoPressed:               return "SettingsView_RateApp_No_Pressed"
            case .shareAppPressed:                return "SettingsView_ShareApp_Pressed"
            case .notificationsSettingsPressed:   return "SettingsView_Notifications_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error), .deleteAccountFail(error: let error):
                return error.eventParameters
            case .colorSchemeChanged(index: let index):
                return ["color_scheme_index": index]
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signOutFail, .deleteAccountFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}
