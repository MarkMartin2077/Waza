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

    @AppStorage("waza_colorSchemeIndex") private var colorSchemeIndex: Int = 0

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
            .tint(presenter.beltAccentColor)
            .onReceive(NotificationCenter.default.publisher(for: .achievementUnlocked)) { notification in
                guard
                    let userInfo = notification.userInfo as? [String: String],
                    let rawValue = userInfo["achievementId"],
                    let id = AchievementId(rawValue: rawValue)
                else { return }
                presenter.onAchievementUnlocked(id)
            }

            if let achievement = presenter.pendingUnlockAchievement {
                AchievementUnlockModal(
                    achievementId: achievement,
                    accentColor: presenter.beltAccentColor,
                    onDismiss: { presenter.onAchievementDismissed() }
                )
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: presenter.pendingUnlockAchievement != nil)
        .preferredColorScheme(resolvedColorScheme)
    }
}

extension CoreBuilder {

    func tabbarView() -> some View {
        TabBarView(
            presenter: TabBarPresenter(interactor: interactor),
            tabs: [
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
            ]
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
                Color.blue.any()
            }),
            TabBarScreen(title: "Progress", systemImage: "chart.line.uptrend.xyaxis", screen: {
                Color.orange.any()
            }),
            TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
                Color.green.any()
            })
        ]
    )
}

#Preview("Real tabs") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return builder.tabbarView()
}
