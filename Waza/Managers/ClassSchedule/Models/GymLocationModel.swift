import Foundation
import IdentifiableByString

struct GymLocationModel: Codable, Sendable, Identifiable, StringIdentifiable {
    var gymId: String
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var geofenceRadius: Double
    var isActive: Bool
    var createdDate: Date

    var id: String { gymId }

    init(
        gymId: String = UUID().uuidString,
        name: String,
        address: String? = nil,
        latitude: Double = 0,
        longitude: Double = 0,
        geofenceRadius: Double = 150,
        isActive: Bool = true,
        createdDate: Date = Date()
    ) {
        self.gymId = gymId
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.geofenceRadius = geofenceRadius
        self.isActive = isActive
        self.createdDate = createdDate
    }

    init(entity: GymLocationEntity) {
        self.gymId = entity.gymId
        self.name = entity.name
        self.address = entity.address
        self.latitude = entity.latitude
        self.longitude = entity.longitude
        self.geofenceRadius = entity.geofenceRadius
        self.isActive = entity.isActive
        self.createdDate = entity.createdDate
    }

    func toEntity() -> GymLocationEntity {
        GymLocationEntity(from: self)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case gymId = "gym_id"
        case name
        case address
        case latitude
        case longitude
        case geofenceRadius = "geofence_radius"
        case isActive = "is_active"
        case createdDate = "created_date"
    }

    // MARK: - Analytics

    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "gym_id": gymId,
            "gym_name": name
        ]
        return dict.compactMapValues { $0 }
    }
}

// MARK: - Mock Data

extension GymLocationModel {
    static var mock: GymLocationModel {
        GymLocationModel(
            gymId: "mock-gym-1",
            name: "Gracie Barra",
            address: "123 Main Street, San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            geofenceRadius: 150,
            isActive: true
        )
    }

    static var mocks: [GymLocationModel] {
        [
            mock,
            GymLocationModel(
                gymId: "mock-gym-2",
                name: "10th Planet Jiu Jitsu",
                address: "456 Oak Ave, San Francisco, CA",
                latitude: 37.7849,
                longitude: -122.4094,
                geofenceRadius: 100,
                isActive: true
            )
        ]
    }
}
