import SwiftUI

struct SessionsView: View {
    @State var presenter: SessionsPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if presenter.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "figure.martial.arts",
                        description: Text("Tap + to log your first training session.")
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(presenter.sessions, id: \.id) { session in
                        SessionRowView(session: session)
                            .anyButton(.press) {
                                presenter.onSessionTapped(session)
                            }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .navigationTitle("Sessions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.accent)
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
