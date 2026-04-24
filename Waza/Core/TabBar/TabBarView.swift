//
//  TabBarView.swift
//  Waza
//
//

import SwiftUI

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}

struct TabBarView: View {

    @State var presenter: TabBarPresenter
    var tabs: [TabBarScreen]

    @AppStorage(Constants.colorSchemeStorageKey) private var colorSchemeIndex: Int = 0

    private var resolvedColorScheme: ColorScheme? {
        switch colorSchemeIndex {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some View {
        ZStack {
            TabView {
                ForEach(tabs) { tab in
                    tab.screen()
                        .tabItem {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                }
            }
            .tint(Color.wazaAccent)
            .onChange(of: presenter.lastUnlockedAchievement) { _, newValue in
                guard let achievementId = newValue else { return }
                presenter.onAchievementUnlocked(achievementId)
            }
            .onChange(of: presenter.lastXPGain) { _, newValue in
                guard let data = newValue else { return }
                presenter.onXPGained(data)
            }
            .onChange(of: presenter.lastFireRoundActivation) { _, newValue in
                guard newValue else { return }
                presenter.onFireRoundActivated()
            }
            .onChange(of: presenter.lastStreakTierUp) { _, newValue in
                guard let tier = newValue else { return }
                presenter.onStreakTierUpDetected(tier)
            }
            .onChange(of: presenter.pendingTechniquePromotion) { _, newValue in
                guard let data = newValue else { return }
                presenter.onPendingTechniquePromotionReceived(data)
            }

            // XP toast — lightweight overlay, not a routed modal
            if let xpData = presenter.pendingXPToast {
                XPGainToastView(
                    data: xpData,
                    accentColor: Color.wazaAccent,
                    onDismiss: { presenter.onXPToastDismissed() }
                )
                .allowsHitTesting(false)
            }
        }
        .preferredColorScheme(resolvedColorScheme)
        .onReceive(NotificationCenter.default.publisher(for: .gymArrival)) { notification in
            guard let gymId = (notification.userInfo as? [String: String])?["gymId"] else { return }
            presenter.onGymArrival(gymId: gymId)
        }
    }
}

extension CoreBuilder {

    func tabbarView(router: AnyRouter) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        return TabBarView(
            presenter: TabBarPresenter(interactor: interactor, router: coreRouter),
            tabs: [
                TabBarScreen(title: "Home", systemImage: "house.fill", screen: {
                    RouterView { router in
                        dashboardView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Train", systemImage: "figure.wrestling", screen: {
                    RouterView { router in
                        trainView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Progress", systemImage: "chart.line.uptrend.xyaxis", screen: {
                    RouterView { router in
                        trainingStatsView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                    RouterView { router in
                        profileView(router: router, delegate: ProfileDelegate())
                    }
                    .any()
                })
            ]
        )
    }

}

#Preview("Real tabs") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.tabbarView(router: router)
    }
}
