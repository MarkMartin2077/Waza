import SwiftUI

struct SessionsView: View {
    @State var presenter: SessionsPresenter

    var body: some View {
        List {
            if let (schedule, gym) = presenter.nextUpcomingClass {
                UpcomingClassCardView(
                    schedule: schedule,
                    gym: gym,
                    onTap: { presenter.onCheckInTapped(gym: gym, schedule: schedule) }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            if presenter.sessions.isEmpty {
                EmptyStateView(
                    icon: "figure.wrestling",
                    title: "No Sessions Yet",
                    subtitle: "Tap + to log your first training session.",
                    actionTitle: nil,
                    onAction: nil
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .scaleAppear(delay: 0.1)
            } else {
                ForEach(Array(presenter.sessions.enumerated()), id: \.element.id) { index, session in
                    SessionRowView(session: session, accentColor: Color.wazaAccent)
                        .staggeredAppear(index: index)
                        .anyButton {
                            presenter.onSessionTapped(session)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // No .destructive role — we show a confirmation alert first
                            Button {
                                presenter.onDeleteSwipeTapped(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: presenter.sessionCount)
        .listStyle(.plain)
        .navigationTitle("Sessions")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(Color.wazaAccent)
                    .accessibilityLabel("Log session")
                    .anyButton {
                        presenter.onLogSessionTapped()
                    }
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

}

// MARK: - Builder Extension

extension CoreBuilder {

    func sessionsView(router: AnyRouter) -> some View {
        SessionsView(
            presenter: SessionsPresenter(
                router: CoreRouter(router: router, builder: self),
                interactor: interactor
            )
        )
    }

}

// MARK: - Preview

#Preview("Sessions - With Data") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.sessionsView(router: router)
    }
}

#Preview("Sessions - Empty") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.sessionsView(router: router)
    }
}
