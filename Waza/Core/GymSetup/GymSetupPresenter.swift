import SwiftUI
import MapKit

@Observable
@MainActor
class GymSetupPresenter {
    private let interactor: GymSetupInteractor
    private let router: GymSetupRouter
    let delegate: GymSetupDelegate

    var gymName: String = ""
    var address: String = ""
    var selectedCoordinate: CLLocationCoordinate2D?
    var radius: Double = 150
    var searchText: String = ""
    var searchResults: [MKMapItem] = []
    var isLoading: Bool = false

    var canSave: Bool {
        !gymName.isEmpty && selectedCoordinate != nil
    }

    init(interactor: GymSetupInteractor, router: GymSetupRouter, delegate: GymSetupDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate

        if let existing = delegate.existingGym {
            gymName = existing.name
            address = existing.address ?? ""
            selectedCoordinate = CLLocationCoordinate2D(latitude: existing.latitude, longitude: existing.longitude)
            radius = existing.geofenceRadius
        }
    }

    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }

    func onCancelTapped() {
        interactor.trackEvent(event: Event.cancelTapped)
        router.dismissScreen()
    }

    func onSearchTextChanged(_ text: String) {
        guard !text.isEmpty else {
            searchResults = []
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        let search = MKLocalSearch(request: request)
        Task {
            if let results = try? await search.start() {
                searchResults = results.mapItems
            }
        }
    }

    func onSearchResultSelected(_ item: MKMapItem) {
        interactor.trackEvent(event: Event.searchResultSelected)
        if #available(iOS 26, macOS 26, *) {
            selectedCoordinate = item.location.coordinate
            address = item.name ?? ""
        } else {
            selectedCoordinate = item.placemark.coordinate
            address = item.placemark.title ?? ""
        }
        if gymName.isEmpty {
            gymName = item.name ?? ""
        }
        searchText = ""
        searchResults = []
    }

    func onMapTapped(coordinate: CLLocationCoordinate2D) {
        interactor.trackEvent(event: Event.mapPinPlaced)
        selectedCoordinate = coordinate
    }

    func onSaveTapped() {
        interactor.trackEvent(event: Event.saveTapped)
        guard let coord = selectedCoordinate else { return }
        isLoading = true
        do {
            if let existing = delegate.existingGym {
                var updated = existing
                updated.name = gymName
                updated.address = address.isEmpty ? nil : address
                updated.latitude = coord.latitude
                updated.longitude = coord.longitude
                updated.geofenceRadius = radius
                try interactor.updateGym(updated)
            } else {
                try interactor.addGym(
                    name: gymName,
                    address: address.isEmpty ? nil : address,
                    latitude: coord.latitude,
                    longitude: coord.longitude,
                    radius: radius
                )
            }
            delegate.onSaved?()
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
        isLoading = false
    }

    func onDeleteTapped() {
        interactor.trackEvent(event: Event.deleteTapped)
        guard let existing = delegate.existingGym else { return }
        do {
            try interactor.deleteGym(existing)
            delegate.onSaved?()
            router.dismissScreen()
        } catch {
            interactor.trackEvent(event: Event.saveFail(error: error))
            router.showAlert(error: error)
        }
    }
}

extension GymSetupPresenter {
    enum Event: LoggableEvent {
        case onAppear
        case cancelTapped
        case searchResultSelected
        case mapPinPlaced
        case saveTapped
        case deleteTapped
        case saveFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:             return "GymSetupView_Appear"
            case .cancelTapped:         return "GymSetupView_Cancel_Tap"
            case .searchResultSelected: return "GymSetupView_SearchResult_Select"
            case .mapPinPlaced:         return "GymSetupView_MapPin_Place"
            case .saveTapped:           return "GymSetupView_Save_Tap"
            case .deleteTapped:         return "GymSetupView_Delete_Tap"
            case .saveFail:             return "GymSetupView_Save_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .saveFail(error: let error): return error.eventParameters
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

struct GymSetupDelegate {
    var existingGym: GymLocationModel?
    var onSaved: (() -> Void)?
}
