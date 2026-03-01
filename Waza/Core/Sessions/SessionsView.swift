import SwiftUI

struct SessionsView: View {
    @State var presenter: SessionsPresenter
    @State private var sessionPendingDelete: BJJSessionModel?

    var body: some View {
        List {
            if let (schedule, gym) = presenter.nextUpcomingClass {
                UpcomingClassCardView(
                    schedule: schedule,
                    gym: gym,
                    onTap: { presenter.onCheckInTapped(gym: gym, schedule: schedule) }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(presenter.beltAccentColor, lineWidth: 2)
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            if presenter.sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "figure.wrestling",
                    description: Text("Tap + to log your first training session.")
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                sessionCountHeader
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))

                ForEach(presenter.sessions, id: \.id) { session in
                    SessionRowView(session: session, accentColor: presenter.beltAccentColor)
                        .anyButton(.press) {
                            presenter.onSessionTapped(session)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                sessionPendingDelete = session
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Sessions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(presenter.beltAccentColor)
                    .anyButton {
                        presenter.onLogSessionTapped()
                    }
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .alert("Delete Session?", isPresented: Binding(
            get: { sessionPendingDelete != nil },
            set: { if !$0 { sessionPendingDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let session = sessionPendingDelete {
                    presenter.onDeleteConfirmed(session)
                }
                sessionPendingDelete = nil
            }
            Button("Cancel", role: .cancel) {
                sessionPendingDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var sessionCountHeader: some View {
        Text("\(presenter.sessionCount) sessions logged")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
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
