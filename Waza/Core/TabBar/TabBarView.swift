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
                    RouterView { _ in
                        gamesPlaceholderView()
                    }
                    .any()
                }),
                TabBarScreen(title: "Analytics", systemImage: "chart.bar.fill", screen: {
                    RouterView { _ in
                        analyticsPlaceholderView()
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

    // Phase 2 placeholder
    private func gamesPlaceholderView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "puzzlepiece.fill")
                .font(.system(size: 48))
                .foregroundStyle(.accent)
            Text("CLA Games")
                .font(.title2)
                .fontWeight(.bold)
            Text("Constraint-Led Approach game library coming in Phase 2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Games")
    }

    // Phase 2 placeholder
    private func analyticsPlaceholderView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundStyle(.accent)
            Text("Analytics")
                .font(.title2)
                .fontWeight(.bold)
            Text("Training analytics and insights coming in Phase 2")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Analytics")
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
