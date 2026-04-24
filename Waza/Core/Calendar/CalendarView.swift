import SwiftUI

struct CalendarView: View {
    @State var presenter: CalendarPresenter

    var body: some View {
        ZStack(alignment: .center) {
            CalendarMonthGridView(
                days: presenter.days,
                monthTitle: presenter.monthTitle,
                onDayTap: { presenter.onDayTapped($0) },
                onPrevMonth: { presenter.onPrevMonth() },
                onNextMonth: { presenter.onNextMonth() },
                onTitleTap: { presenter.onJumpToToday() }
            )

            if presenter.isFirstRunEmpty {
                emptyStateOverlay
                    .allowsHitTesting(false)
            }
        }
        .background(Color.wazaPaper)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !presenter.isOnCurrentMonth {
                    Button("Today") { presenter.onJumpToToday() }
                        .font(.wazaLabel)
                        .foregroundStyle(Color.wazaAccent)
                        .accessibilityIdentifier("calendar.todayButton")
                }
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
    }

    private var emptyStateOverlay: some View {
        VStack(spacing: 8) {
            Text("技")
                .font(.system(size: 44))
                .foregroundStyle(Color.wazaInk300)
            Text("Log your first session to see it here.")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk500)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func calendarView(router: AnyRouter, delegate: CalendarDelegate = CalendarDelegate()) -> some View {
        CalendarView(
            presenter: CalendarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

// MARK: - Previews

#Preview("Calendar - Signed In") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.calendarView(router: router)
    }
}

#Preview("Calendar - Empty") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.calendarView(router: router)
    }
}
