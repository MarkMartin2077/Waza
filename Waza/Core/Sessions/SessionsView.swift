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
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
            }

            filterBar
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

            if presenter.filteredSessions.isEmpty {
                emptyState
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                if presenter.hasActiveFilters || presenter.isSearching {
                    resultsCount
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }

                sessionSections
            }
        }
        .listStyle(.plain)
        .searchable(text: $presenter.searchText, prompt: "Search techniques, notes...")
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

    // MARK: - Filter Bar

    private var filterBar: some View {
        SessionFilterBarView(
            selectedSessionTypes: presenter.selectedSessionTypes,
            selectedAcademy: presenter.selectedAcademy,
            selectedMood: presenter.selectedMood,
            availableAcademies: presenter.availableAcademies,
            sessionTypeLabel: presenter.sessionTypeFilterLabel,
            academyLabel: presenter.academyFilterLabel,
            moodLabel: presenter.moodFilterLabel,
            hasActiveFilters: presenter.hasActiveFilters,
            onTypeToggled: { presenter.onSessionTypeToggled($0) },
            onAcademySelected: { presenter.onAcademySelected($0) },
            onMoodSelected: { presenter.onMoodSelected($0) },
            onClearFilters: { presenter.onClearFilters() }
        )
    }

    // MARK: - Results Count

    private var resultsCount: some View {
        Text("\(presenter.filteredCount) of \(presenter.totalCount) sessions")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        Group {
            if presenter.hasActiveFilters || presenter.isSearching {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Matches",
                    subtitle: "Try adjusting your search or filters.",
                    actionTitle: "Clear Filters",
                    onAction: { presenter.onClearFilters() }
                )
            } else {
                EmptyStateView(
                    icon: "figure.wrestling",
                    title: "No Sessions Yet",
                    subtitle: "Tap + to log your first training session.",
                    actionTitle: nil,
                    onAction: nil
                )
            }
        }
        .scaleAppear(delay: 0.1)
    }

    // MARK: - Session Sections

    private var sessionSections: some View {
        ForEach(presenter.groupedSessions) { group in
            Section {
                ForEach(Array(group.sessions.enumerated()), id: \.element.id) { index, session in
                    SessionRowView(session: session, accentColor: Color.wazaAccent)
                        .staggeredAppear(index: index)
                        .anyButton {
                            presenter.onSessionTapped(session)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                presenter.onDeleteSwipeTapped(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
            } header: {
                sectionHeader(title: group.title, count: group.sessions.count)
            }
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(count)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemGray5), in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets())
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
