import SwiftUI

@Observable
@MainActor
class TrainPresenter {

    enum Segment: String, CaseIterable, Identifiable {
        case history = "History"
        case techniques = "Techniques"
        case schedule = "Schedule"

        var id: String { rawValue }

        var kanji: String {
            switch self {
            case .history:    return "録"
            case .techniques: return "技"
            case .schedule:   return "時"
            }
        }
    }

    let router: any TrainRouter
    let interactor: any TrainInteractor

    var selectedSegment: Segment = .history

    init(router: any TrainRouter, interactor: any TrainInteractor) {
        self.router = router
        self.interactor = interactor
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onSegmentSelected(_ segment: Segment) {
        guard segment != selectedSegment else { return }
        interactor.trackEvent(event: Event.segmentChanged(segment: segment))
        selectedSegment = segment
    }

    func onLogSessionTapped() {
        interactor.trackEvent(event: Event.logSessionTapped)
        router.showSessionEntryView(onDismiss: nil)
    }
}

extension TrainPresenter {

    enum Event: LoggableEvent {
        case onAppear
        case segmentChanged(segment: TrainPresenter.Segment)
        case logSessionTapped

        var eventName: String {
            switch self {
            case .onAppear:         return "TrainView_Appear"
            case .segmentChanged:   return "TrainView_SegmentChanged"
            case .logSessionTapped: return "TrainView_LogSession_Tap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .segmentChanged(segment: let segment):
                return ["segment": segment.rawValue]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
