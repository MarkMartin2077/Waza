import SwiftUI

@Observable
@MainActor
class SessionDetailPresenter {
    private let interactor: SessionDetailInteractor
    private let router: SessionDetailRouter
    let delegate: SessionDetailDelegate

    var session: BJJSessionModel
    var isEditing: Bool = false

    // Editable fields
    var editNotes: String = ""
    var editWhatWorked: String = ""
    var editNeedsImprovement: String = ""
    var editKeyInsights: String = ""

    init(interactor: SessionDetailInteractor, router: SessionDetailRouter, delegate: SessionDetailDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
        self.session = delegate.session
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        loadEditFields()
    }

    private func loadEditFields() {
        editNotes = session.notes ?? ""
        editWhatWorked = session.whatWorkedWell ?? ""
        editNeedsImprovement = session.needsImprovement ?? ""
        editKeyInsights = session.keyInsights ?? ""
    }

    func onEditPressed() {
        interactor.trackEvent(event: Event.editPressed)
        isEditing = true
    }

    func onSaveEditPressed() {
        interactor.trackEvent(event: Event.saveEditPressed)
        session.notes = editNotes.isEmpty ? nil : editNotes
        session.whatWorkedWell = editWhatWorked.isEmpty ? nil : editWhatWorked
        session.needsImprovement = editNeedsImprovement.isEmpty ? nil : editNeedsImprovement
        session.keyInsights = editKeyInsights.isEmpty ? nil : editKeyInsights

        do {
            try interactor.updateSession(session)
            isEditing = false
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }

    func onCancelEditPressed() {
        interactor.trackEvent(event: Event.cancelEditPressed)
        loadEditFields()
        isEditing = false
    }

    func onDeletePressed() {
        interactor.trackEvent(event: Event.deletePressed)
        router.showAlert(.alert, title: "Delete this session?", subtitle: "This action cannot be undone.") {
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

    var beltAccentColor: Color {
        .wazaAccent
    }

    func onTechniqueTagTapped(_ name: String) {
        interactor.trackEvent(event: Event.techniqueTagTapped(name: name))
        if let technique = interactor.allTechniques.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
            router.showTechniqueDetailView(technique: technique)
        } else {
            router.showCreateTechniqueAlert(name: name) { [weak self] in
                self?.createAndShowTechnique(name)
            }
        }
    }

    private func createAndShowTechnique(_ name: String) {
        interactor.createTechnique(name: name, category: TechniqueCategory.infer(from: name))
        guard let technique = interactor.allTechniques.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else { return }
        router.showTechniqueDetailView(technique: technique)
    }

    func onDeleteConfirmed() {
        interactor.trackEvent(event: Event.deleteConfirmed)
        do {
            try interactor.deleteSession(session)
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }
}

extension SessionDetailPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case editPressed
        case cancelEditPressed
        case saveEditPressed
        case deletePressed
        case deleteConfirmed
        case saveFail(error: Error)
        case techniqueTagTapped(name: String)

        var eventName: String {
            switch self {
            case .onAppear:              return "SessionDetailView_Appear"
            case .editPressed:           return "SessionDetailView_Edit_Press"
            case .cancelEditPressed:     return "SessionDetailView_CancelEdit_Press"
            case .saveEditPressed:       return "SessionDetailView_SaveEdit_Press"
            case .deletePressed:         return "SessionDetailView_Delete_Press"
            case .deleteConfirmed:       return "SessionDetailView_Delete_Confirm"
            case .saveFail:              return "SessionDetailView_Save_Fail"
            case .techniqueTagTapped:    return "SessionDetailView_TechniqueTag_Tap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .saveFail(error: let error):       return error.eventParameters
            case .techniqueTagTapped(name: let name): return ["technique_name": name]
            default: return nil
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

struct SessionDetailDelegate {
    let session: BJJSessionModel
    var eventParameters: [String: Any]? { nil }
}
