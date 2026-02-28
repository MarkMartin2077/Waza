import SwiftUI

@MainActor
protocol GymSetupInteractor: GlobalInteractor {
    @discardableResult
    func addGym(name: String, address: String?, latitude: Double, longitude: Double, radius: Double) throws -> GymLocationModel
    func updateGym(_ gym: GymLocationModel) throws
    func deleteGym(_ gym: GymLocationModel) throws
}

extension CoreInteractor: GymSetupInteractor { }
