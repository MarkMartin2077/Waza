import SwiftData
import Foundation

@Model
final class GymLocationEntity {
    @Attribute(.unique) var gymId: String
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var geofenceRadius: Double
    var isActive: Bool
    var createdDate: Date

    init(
        gymId: String = UUID().uuidString,
        name: String = "",
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

    convenience init(from model: GymLocationModel) {
        self.init(
            gymId: model.gymId,
            name: model.name,
            address: model.address,
            latitude: model.latitude,
            longitude: model.longitude,
            geofenceRadius: model.geofenceRadius,
            isActive: model.isActive,
            createdDate: model.createdDate
        )
    }

    func toModel() -> GymLocationModel {
        GymLocationModel(entity: self)
    }

    func update(from model: GymLocationModel) {
        name = model.name
        address = model.address
        latitude = model.latitude
        longitude = model.longitude
        geofenceRadius = model.geofenceRadius
        isActive = model.isActive
    }
}
