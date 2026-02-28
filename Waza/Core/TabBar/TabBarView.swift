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

    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                tab.screen()
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
        .tint(presenter.beltAccentColor)
    }
}

extension CoreBuilder {

    func tabbarView() -> some View {
        TabBarView(
            presenter: TabBarPresenter(interactor: interactor),
            tabs: [
                TabBarScreen(title: "Today", systemImage: "sun.max.fill", screen: {
                    RouterView { router in
                        dashboardView(router: router, delegate: DashboardDelegate())
                    }
                    .any()
                }),
                TabBarScreen(title: "Sessions", systemImage: "figure.martial.arts", screen: {
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
            TabBarScreen(title: "Today", systemImage: "sun.max.fill", screen: {
                Color.red.any()
            }),
            TabBarScreen(title: "Sessions", systemImage: "figure.martial.arts", screen: {
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
