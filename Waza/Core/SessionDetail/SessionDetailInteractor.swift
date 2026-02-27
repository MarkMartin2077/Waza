import SwiftUI

@MainActor
protocol SessionDetailInteractor: GlobalInteractor {
    func updateSession(_ session: BJJSessionModel) throws
    func deleteSession(_ session: BJJSessionModel) throws
}

extension CoreInteractor: SessionDetailInteractor { }
