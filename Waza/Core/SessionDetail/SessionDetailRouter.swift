import SwiftUI

@MainActor
protocol SessionDetailRouter: GlobalRouter {
    func showTechniqueDetailView(technique: TechniqueModel)
    func showCreateTechniqueAlert(name: String, onConfirm: @escaping @MainActor @Sendable () -> Void)
}

extension CoreRouter: SessionDetailRouter {
    func showCreateTechniqueAlert(name: String, onConfirm: @escaping @MainActor @Sendable () -> Void) {
        showAlert(.alert, title: "Create Technique?", subtitle: "Add \"\(name)\" to your technique journal?") {
            AnyView(
                VStack {
                    Button("Add to Journal") { onConfirm() }
                    Button("Cancel", role: .cancel) { }
                }
            )
        }
    }
}
