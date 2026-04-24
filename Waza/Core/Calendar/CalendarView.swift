import SwiftUI

struct CalendarView: View {
    @State var presenter: CalendarPresenter

    var body: some View {
        VStack(spacing: 0) {
            if presenter.isFirstRunEmpty {
                emptyStateBanner
            }
            CalendarMonthGridView(
                days: presenter.days,
                monthTitle: presenter.monthTitle,
                onDayTap: { presenter.onDayTapped($0) },
                onPrevMonth: { presenter.onPrevMonth() },
                onNextMonth: { presenter.onNextMonth() },
                onTitleTap: { presenter.onJumpToToday() }
            )
            Spacer(minLength: 0)
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

    private var emptyStateBanner: some View {
        HStack(spacing: 12) {
            Text("技")
                .font(.system(size: 28))
                .foregroundStyle(Color.wazaAccent)
            Text("Log your first session to see it here.")
                .font(.wazaBody)
                .foregroundStyle(Color.wazaInk600)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.wazaPaperHi)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.wazaInk300)
                .frame(height: 0.5)
        }
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
