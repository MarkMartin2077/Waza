import SwiftUI

@Observable
@MainActor
class TechniqueJournalPresenter {
    private let router: any TechniqueJournalRouter
    private let interactor: any TechniqueJournalInteractor

    var searchText: String = ""

    /// Pre-computed session stats per technique name, rebuilt when data changes.
    private var sessionStatsCache: [String: TechniqueSessionStats] = [:]

    init(router: any TechniqueJournalRouter, interactor: any TechniqueJournalInteractor) {
        self.router = router
        self.interactor = interactor
    }

    // MARK: - Computed Properties

    var groupedTechniques: [(category: TechniqueCategory, techniques: [TechniqueModel])] {
        let filtered = filteredTechniques
        guard !filtered.isEmpty else { return [] }

        var dict: [TechniqueCategory: [TechniqueModel]] = [:]
        for technique in filtered {
            dict[technique.category, default: []].append(technique)
        }

        return TechniqueCategory.allCases.compactMap { category in
            guard let techniques = dict[category], !techniques.isEmpty else { return nil }
            return (category: category, techniques: techniques.sorted { $0.name < $1.name })
        }
    }

    private var filteredTechniques: [TechniqueModel] {
        let all = interactor.allTechniques
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return all }
        let query = searchText.lowercased()
        return all.filter {
            $0.name.lowercased().contains(query)
            || $0.category.displayName.lowercased().contains(query)
            || $0.stage.displayName.lowercased().contains(query)
            || $0.notes?.lowercased().contains(query) == true
        }
    }

    func practiceCount(for technique: TechniqueModel) -> Int {
        sessionStatsCache[technique.name.lowercased()]?.count ?? 0
    }

    func lastPracticed(for technique: TechniqueModel) -> Date? {
        sessionStatsCache[technique.name.lowercased()]?.lastDate
    }

    func promotionSuggestion(for technique: TechniqueModel) -> ProgressionStage? {
        ProgressionStage.suggestedPromotion(
            currentStage: technique.stage,
            practiceCount: practiceCount(for: technique)
        )
    }

    // MARK: - Actions

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
        rebuildSessionStatsCache()
    }

    func onTechniqueTapped(_ technique: TechniqueModel) {
        interactor.trackEvent(event: Event.techniqueTapped(name: technique.name, techniqueId: technique.techniqueId))
        router.showTechniqueDetailView(technique: technique)
    }

    func onAddTechniqueTapped() {
        interactor.trackEvent(event: Event.addTechniqueTapped)
        router.showAddTechniqueView(onSave: { [weak self] name, category in
            self?.onAddTechniqueSaved(name: name, category: category)
        })
    }

    private func onAddTechniqueSaved(name: String, category: TechniqueCategory) {
        interactor.trackEvent(event: Event.addTechniqueSaved(name: name, category: category.rawValue))
        interactor.createTechnique(name: name, category: category)
    }

    func filteredTechniqueByName(_ name: String) -> TechniqueModel? {
        interactor.allTechniques.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    // MARK: - Private

    private func rebuildSessionStatsCache() {
        var cache: [String: TechniqueSessionStats] = [:]
        for session in interactor.allSessions {
            for area in session.focusAreas {
                let key = area.lowercased()
                var stats = cache[key] ?? TechniqueSessionStats(count: 0, lastDate: nil)
                stats.count += 1
                if let existing = stats.lastDate {
                    if session.date > existing { stats.lastDate = session.date }
                } else {
                    stats.lastDate = session.date
                }
                cache[key] = stats
            }
        }
        sessionStatsCache = cache
    }
}

// MARK: - Session Stats Cache Entry

private struct TechniqueSessionStats {
    var count: Int
    var lastDate: Date?
}

// MARK: - Events

extension TechniqueJournalPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case techniqueTapped(name: String, techniqueId: String)
        case addTechniqueTapped
        case addTechniqueSaved(name: String, category: String)

        var eventName: String {
            switch self {
            case .onAppear:            return "TechniqueJournalView_Appear"
            case .techniqueTapped:     return "TechniqueJournalView_TechniqueTap"
            case .addTechniqueTapped:  return "TechniqueJournalView_AddTechnique_Tap"
            case .addTechniqueSaved:   return "TechniqueJournalView_AddTechnique_Saved"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .techniqueTapped(name: let name, techniqueId: let techniqueId):
                return ["technique_name": name, "technique_id": techniqueId]
            case .addTechniqueSaved(name: let name, category: let category):
                return ["technique_name": name, "category": category]
            default:
                return nil
            }
        }

        var type: LogType { .analytic }
    }
}
