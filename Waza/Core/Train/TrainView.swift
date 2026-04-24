import SwiftUI

struct TrainView<HistoryContent: View, TechniquesContent: View, ScheduleContent: View>: View {

    @State var presenter: TrainPresenter
    @ViewBuilder let historyContent: HistoryContent
    @ViewBuilder let techniquesContent: TechniquesContent
    @ViewBuilder let scheduleContent: ScheduleContent

    var body: some View {
        VStack(spacing: 0) {
            segmentedControl
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color.wazaPaper)

            Divider()

            Group {
                switch presenter.selectedSegment {
                case .history:    historyContent
                case .techniques: techniquesContent
                case .schedule:   scheduleContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.wazaPaper)
        .onAppear {
            presenter.onViewAppear()
        }
    }

    private var segmentedControl: some View {
        HStack(spacing: 6) {
            ForEach(TrainPresenter.Segment.allCases) { segment in
                segmentPill(segment)
            }
        }
    }

    private func segmentPill(_ segment: TrainPresenter.Segment) -> some View {
        let isSelected = presenter.selectedSegment == segment
        return Text(segment.rawValue)
            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? Color.wazaPaperHi : Color.wazaInk700)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: .wazaCornerSmall)
                    .fill(isSelected ? Color.wazaAccent : Color.wazaInk100)
            )
            .anyButton(.press) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    presenter.onSegmentSelected(segment)
                }
            }
    }
}

// MARK: - CoreBuilder Extension

extension CoreBuilder {

    func trainView(router: AnyRouter) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        return TrainView(
            presenter: TrainPresenter(router: coreRouter, interactor: interactor),
            historyContent: { self.sessionsView(router: router) },
            techniquesContent: { self.techniqueJournalView(router: router) },
            scheduleContent: { self.classScheduleView(router: router) }
        )
    }

}

// MARK: - Previews

#Preview("Train - History") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        builder.trainView(router: router)
    }
}
