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
    }
}

extension CoreBuilder {

    func tabbarView() -> some View {
        TabBarView(
            tabs: [
                TabBarScreen(title: "Dashboard", systemImage: "house.fill", screen: {
                    RouterView { router in
                        dashboardView(router: router, delegate: DashboardDelegate())
                    }
                    .any()
                }),
                TabBarScreen(title: "Games", systemImage: "puzzlepiece.fill", screen: {
                    RouterView { router in
                        claGamesLibraryView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Analytics", systemImage: "chart.bar.fill", screen: {
                    RouterView { router in
                        trainingStatsView(router: router)
                    }
                    .any()
                }),
                TabBarScreen(title: "Goals", systemImage: "target", screen: {
                    RouterView { router in
                        goalsPlanningView(router: router, delegate: GoalsPlanningDelegate())
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
    TabBarView(tabs: [
        TabBarScreen(title: "Dashboard", systemImage: "house.fill", screen: {
            Color.red.any()
        }),
        TabBarScreen(title: "Games", systemImage: "puzzlepiece.fill", screen: {
            Color.blue.any()
        }),
        TabBarScreen(title: "Profile", systemImage: "person.fill", screen: {
            Color.green.any()
        })
    ])
}

#Preview("Real tabs") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return builder.tabbarView()
}
