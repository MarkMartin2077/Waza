import SwiftUI

@Observable
@MainActor
class TrainPresenter {

    enum Segment: String, CaseIterable, Identifiable {
        case calendar = "Calendar"
        case techniques = "Techniques"

        var id: String { rawValue }

        var kanji: String {
            switch self {
            case .calendar:   return "暦"
            case .techniques: return "技"
            }
        }
    }

    let router: any TrainRouter
    let interactor: any TrainInteractor

    var selectedSegment: Segment = .calendar

    init(router: any TrainRouter, interactor: any TrainInteractor) {
        self.router = router
        self.interactor = interactor
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onSegmentSelected(_ segment: Segment) {
        guard segment != selectedSegment else { return }
        let previous = selectedSegment
        interactor.trackEvent(event: Event.segmentChanged(fromSegment: previous, toSegment: segment))
        selectedSegment = segment
    }
}

extension TrainPresenter {

    enum Event: LoggableEvent {
        case onAppear
        case segmentChanged(fromSegment: TrainPresenter.Segment, toSegment: TrainPresenter.Segment)

        var eventName: String {
            switch self {
            case .onAppear:       return "TrainView_Appear"
            case .segmentChanged: return "TrainView_SegmentChanged"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .segmentChanged(fromSegment: let fromSegment, toSegment: let toSegment):
                return ["from_segment": fromSegment.rawValue, "to_segment": toSegment.rawValue]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
