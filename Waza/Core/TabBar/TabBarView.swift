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
    var builder: CoreBuilder?

    @AppStorage(Constants.colorSchemeStorageKey) private var colorSchemeIndex: Int = 0

    private var resolvedColorScheme: ColorScheme? {
        switch colorSchemeIndex {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some View {
        // ZStack instead of .overlay — avoids the invisible hit-test layer that
        // .overlay creates over TabView, which caused toolbar buttons to need two taps.
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
                guard let id = newValue else { return }
                presenter.onAchievementUnlocked(id)
            }

            if let achievement = presenter.pendingUnlockAchievement {
                AchievementUnlockModal(
                    achievementId: achievement,
                    accentColor: Color.wazaAccent,
                    onDismiss: { presenter.onAchievementDismissed() }
                )
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: presenter.pendingUnlockAchievement != nil)
        .preferredColorScheme(resolvedColorScheme)
        .onReceive(NotificationCenter.default.publisher(for: .gymArrival)) { notification in
            guard let gymId = (notification.userInfo as? [String: String])?["gymId"] else { return }
            presenter.onGymArrival(gymId: gymId)
        }
        // TabBar is the root container without a VIPER Router, so .sheet is
        // acceptable here. The presenter still drives the show/dismiss logic.
        .sheet(isPresented: Binding(
            get: { presenter.pendingCheckIn != nil },
            set: { if !$0 { presenter.onCheckInDismissed() } }
        )) {
            if let pendingCheckIn = presenter.pendingCheckIn, let builder {
                RouterView { router in
                    builder.checkInView(
                        router: router,
                        delegate: CheckInDelegate(gym: pendingCheckIn.gym, matchedSchedule: pendingCheckIn.schedule, checkInMethod: .geofence)
                    )
                }
            }
        }
    }
}

extension CoreBuilder {

    func tabbarView() -> some View {
        TabBarView(
            presenter: TabBarPresenter(interactor: interactor),
            tabs: [
                TabBarScreen(title: "Home", systemImage: "house.fill", screen: {
                    RouterView { router in
                        dashboardView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Sessions", systemImage: "list.bullet", screen: {
                    RouterView { router in
                        sessionsView(router: router)
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
            ],
            builder: self
        )
    }

}

#Preview("Fake tabs") {
    let container = DevPreview.shared.container()
    let presenter = TabBarPresenter(interactor: CoreInteractor(container: container))

    return TabBarView(
        presenter: presenter,
        tabs: [
            TabBarScreen(title: "Sessions", systemImage: "list.bullet", screen: {
                Color.wazaAccent.any()
            }),
            TabBarScreen(title: "Progress", systemImage: "chart.line.uptrend.xyaxis", screen: {
                Color.orange.any()
            }),
            TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                Color.green.any()
            })
        ],
        builder: nil
    )
}

#Preview("Real tabs") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return builder.tabbarView()
}
