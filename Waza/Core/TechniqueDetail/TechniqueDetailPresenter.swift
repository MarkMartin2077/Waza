import SwiftUI

@Observable
@MainActor
class TechniqueDetailPresenter {
    private let interactor: any TechniqueDetailInteractor
    private let router: any TechniqueDetailRouter

    var technique: TechniqueModel
    var editNotes: String = ""

    init(interactor: any TechniqueDetailInteractor, router: any TechniqueDetailRouter, technique: TechniqueModel) {
        self.interactor = interactor
        self.router = router
        self.technique = technique
        self.editNotes = technique.notes ?? ""
    }

    // MARK: - Computed Properties (filtered once, not per-property)

    var relatedSessions: [BJJSessionModel] {
        interactor.allSessions.filter { session in
            session.focusAreas.contains { area in
                area.caseInsensitiveCompare(technique.name) == .orderedSame
            }
        }.sorted { $0.date > $1.date }
    }

    var practiceCount: Int { relatedSessions.count }

    var lastPracticed: Date? { relatedSessions.first?.date }

    var promotionSuggestion: ProgressionStage? {
        ProgressionStage.suggestedPromotion(
            currentStage: technique.stage,
            practiceCount: practiceCount
        )
    }

    // MARK: - Actions

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onStageChanged(_ stage: ProgressionStage) {
        interactor.trackEvent(event: Event.stageChanged(stage: stage))
        technique.stage = stage
        technique.lastStageChangeDate = Date()
        saveTechnique()
    }

    func onCategoryChanged(_ category: TechniqueCategory) {
        interactor.trackEvent(event: Event.categoryChanged(category: category))
        technique.category = category
        saveTechnique()
    }

    func onNotesSaved(_ notes: String) {
        interactor.trackEvent(event: Event.notesSaved)
        technique.notes = notes.isEmpty ? nil : notes
        saveTechnique()
    }

    func onDeletePressed() {
        interactor.trackEvent(event: Event.deletePressed)
        router.showAlert(.alert, title: "Delete Technique?", subtitle: "This action cannot be undone.") {
            AnyView(
                Group {
                    Button("Delete", role: .destructive) { [weak self] in
                        self?.onDeleteConfirmed()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            )
        }
    }

    func onSessionTapped(_ session: BJJSessionModel) {
        interactor.trackEvent(event: Event.sessionTapped)
        router.showSessionDetailView(session: session)
    }

    // MARK: - Private

    private func saveTechnique() {
        do {
            try interactor.updateTechnique(technique)
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }

    private func onDeleteConfirmed() {
        interactor.trackEvent(event: Event.deleteConfirmed)
        do {
            try interactor.deleteTechnique(technique)
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }
}

// MARK: - Events

extension TechniqueDetailPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case stageChanged(stage: ProgressionStage)
        case categoryChanged(category: TechniqueCategory)
        case notesSaved
        case deletePressed
        case deleteConfirmed
        case sessionTapped
        case saveFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:          return "TechniqueDetailView_Appear"
            case .stageChanged:      return "TechniqueDetailView_Stage_Change"
            case .categoryChanged:   return "TechniqueDetailView_Category_Change"
            case .notesSaved:        return "TechniqueDetailView_Notes_Save"
            case .deletePressed:     return "TechniqueDetailView_Delete_Press"
            case .deleteConfirmed:   return "TechniqueDetailView_Delete_Confirm"
            case .sessionTapped:     return "TechniqueDetailView_Session_Tap"
            case .saveFail:          return "TechniqueDetailView_Save_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .stageChanged(stage: let stage):
                return ["stage": stage.rawValue]
            case .categoryChanged(category: let category):
                return ["category": category.rawValue]
            case .saveFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .saveFail: return .severe
            default: return .analytic
            }
        }
    }
}
