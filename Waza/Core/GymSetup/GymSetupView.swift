import SwiftUI
import MapKit

struct GymSetupView: View {
    @State var presenter: GymSetupPresenter
    let delegate: GymSetupDelegate

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                locationSection
                radiusSection
                if delegate.existingGym != nil {
                    deleteSection
                }
            }
            .navigationTitle(delegate.existingGym == nil ? "Add Gym" : "Edit Gym")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { presenter.onCancelTapped() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { presenter.onSaveTapped() }
                        .fontWeight(.semibold)
                        .disabled(!presenter.canSave)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { presenter.errorMessage != nil },
                set: { if !$0 { presenter.errorMessage = nil } }
            )) {
                Button("OK") { presenter.errorMessage = nil }
            } message: {
                Text(presenter.errorMessage ?? "")
            }
            .onAppear {
                presenter.onViewAppear()
            }
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        Section("Gym Name") {
            TextField("e.g. Gracie Barra", text: $presenter.gymName)
        }
    }

    // MARK: - Location

    private var locationSection: some View {
        Section("Location") {
            TextField("Search for gym address…", text: $presenter.searchText)
                .onChange(of: presenter.searchText) { _, new in
                    presenter.onSearchTextChanged(new)
                }

            if !presenter.searchResults.isEmpty {
                ForEach(presenter.searchResults, id: \.self) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name ?? "Unknown")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        searchResultSubtitle(item: item)
                    }
                    .anyButton {
                        presenter.onSearchResultSelected(item)
                    }
                }
            }

            if let coord = presenter.selectedCoordinate {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))) {
                    Marker(presenter.gymName.isEmpty ? "Gym" : presenter.gymName, coordinate: coord)
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture { /* allow map interaction */ }

                Text(presenter.address.isEmpty ? "Tap the map to adjust" : presenter.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Search above to pin your gym location.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Search Result Subtitle

    @ViewBuilder
    private func searchResultSubtitle(item: MKMapItem) -> some View {
        if #available(iOS 26, macOS 26, *) {
            EmptyView()
        } else {
            if let title = item.placemark.title {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Radius

    private var radiusSection: some View {
        Section("Auto Check-In Radius: \(Int(presenter.radius)) m") {
            Slider(value: $presenter.radius, in: 50...500, step: 10)
                .tint(.accent)
        }
    }

    // MARK: - Delete

    private var deleteSection: some View {
        Section {
            Button("Delete Gym", role: .destructive) {
                presenter.onDeleteTapped()
            }
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func gymSetupView(router: AnyRouter, delegate: GymSetupDelegate = GymSetupDelegate()) -> some View {
        GymSetupView(
            presenter: GymSetupPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showGymSetupView(existingGym: GymLocationModel? = nil, onDismiss: (() -> Void)? = nil) {
        let delegate = GymSetupDelegate(existingGym: existingGym, onSaved: onDismiss)
        router.showScreen(.sheet) { router in
            builder.gymSetupView(router: router, delegate: delegate)
        }
    }

}

// MARK: - Preview

#Preview("Add Gym") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.gymSetupView(router: router)
    }
}
