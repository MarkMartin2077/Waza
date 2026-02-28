import Foundation
import CoreLocation

// MARK: - Delegate Protocol

@MainActor
protocol GeofenceCoordinatorDelegate: AnyObject {
    func didEnterGym(_ gym: GymLocationModel)
}

// MARK: - GeofenceCoordinator
@MainActor
final class GeofenceCoordinator: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    private let locationManager = CLLocationManager()
    private var monitoredGyms: [String: GymLocationModel] = [:]

    weak var delegate: (any GeofenceCoordinatorDelegate)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoring(gyms: [GymLocationModel]) {
        for gym in gyms where gym.isActive {
            monitoredGyms[gym.gymId] = gym
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: gym.latitude, longitude: gym.longitude),
                radius: gym.geofenceRadius,
                identifier: gym.gymId
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false
            locationManager.startMonitoring(for: region)
        }
    }

    func stopMonitoring(gymId: String) {
        monitoredGyms.removeValue(forKey: gymId)
        for region in locationManager.monitoredRegions where region.identifier == gymId {
            locationManager.stopMonitoring(for: region)
        }
    }

    func stopAllMonitoring() {
        monitoredGyms.removeAll()
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // Extract String (Sendable) before hopping actors — CLRegion is not Sendable
        let identifier = region.identifier
        Task { @MainActor in
            guard let gym = self.monitoredGyms[identifier] else { return }
            self.delegate?.didEnterGym(gym)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: any Error) {
        #if DEBUG
        print("🚨 Geofence monitoring failed for \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
        #endif
    }
}
