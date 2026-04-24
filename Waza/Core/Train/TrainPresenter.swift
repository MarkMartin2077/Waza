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
        let from = selectedSegment
        interactor.trackEvent(event: Event.segmentChanged(from: from, to: segment))
        selectedSegment = segment
    }
}

extension TrainPresenter {

    enum Event: LoggableEvent {
        case onAppear
        case segmentChanged(from: TrainPresenter.Segment, to: TrainPresenter.Segment)

        var eventName: String {
            switch self {
            case .onAppear:       return "TrainView_Appear"
            case .segmentChanged: return "TrainView_SegmentChanged"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .segmentChanged(from: let from, to: let to):
                return ["from_segment": from.rawValue, "to_segment": to.rawValue]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
