import SwiftUI
import PhotosUI

struct ProfileDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ProfileView: View {

    @State var presenter: ProfilePresenter
    let delegate: ProfileDelegate
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                    .scaleAppear(delay: 0)
                XPProgressBarView(
                    levelInfo: presenter.xpLevelInfo,
                    accentColor: .wazaAccent
                )
                .scaleAppear(delay: 0.03)
                ActiveBoostView(
                    streakTier: presenter.streakTier,
                    fireRoundExpiresAt: presenter.fireRoundExpiresAt,
                    perfectWeekActive: presenter.perfectWeekActive
                )
                .scaleAppear(delay: 0.04)
                statsSection
                    .scaleAppear(delay: 0.06)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            // Separate ToolbarItems so iOS 26 renders each as its own liquid-glass capsule.
            if let image = presenter.shareCardImage {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("My Waza Stats", image: Image(uiImage: image))
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(Color.wazaAccent)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            avatarPicker
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task { await handlePhotoSelection(newItem) }
                }

            Text(presenter.userName)
                .font(.wazaDisplayMedium)

            if presenter.isPremium {
                Label("Premium", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.15), in: Capsule())
            }
        }
        .padding(.vertical, 8)
    }

    /// Tappable avatar — shows existing profile image if available, falls back to
    /// initials. Opens the system photo picker on tap.
    ///
    /// The label content is extracted into a dedicated `View` struct (`AvatarLabelView`)
    /// rather than an instance method so that constructing it inside `PhotosPicker`'s
    /// `label:` closure doesn't cross a main-actor boundary — construction is a plain
    /// value init, and the view's own body runs on main at render time through `View`
    /// conformance.
    private var avatarPicker: some View {
        // Read presenter state into local Sendable primitives *before* entering the
        // PhotosPicker closure — the label closure is @Sendable and can't touch
        // main-actor-isolated state directly.
        let imageURL = presenter.profileImageURL
        let localImage = presenter.pendingLocalImage
        let userName = presenter.userName
        let isUploading = presenter.isUploadingProfileImage

        return PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            AvatarLabelView(
                imageURL: imageURL,
                localImage: localImage,
                userName: userName,
                isUploading: isUploading
            )
        }
        .accessibilityLabel("Change profile photo")
    }

    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        defer { selectedPhotoItem = nil }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                presenter.onProfileImageLoadFailed(error: nil)
                return
            }
            guard let image = UIImage(data: data) else {
                presenter.onProfileImageLoadFailed(error: nil)
                return
            }
            presenter.onProfileImageSelected(image)
        } catch {
            presenter.onProfileImageLoadFailed(error: error)
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            profileStat(value: "\(presenter.streakCount)", label: "Day Streak")
            profileStat(value: "\(presenter.sessionStats.thisWeekSessions)", label: "This Week")
            profileStat(value: "\(presenter.sessionStats.totalSessions)", label: "Sessions")
            profileStat(value: presenter.totalTrainingHoursText, label: "Hrs Trained")
        }
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.wazaNumSmall)
                .foregroundStyle(Color.wazaInk900)
                .contentTransition(.numericText())
            Text(label)
                .font(.wazaLabel)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .wazaCard()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(Color.wazaAccent)
            .anyButton(.press) {
                presenter.onSettingsButtonPressed()
            }
            .accessibilityLabel("Settings")
    }
}

#Preview("Full Profile") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProfileDelegate()

    return RouterView { router in
        builder.profileView(router: router, delegate: delegate)
    }
}

#Preview("Empty State") {
    let preview = DevPreview(isSignedIn: false)
    let container = preview.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProfileDelegate()

    return RouterView { router in
        builder.profileView(router: router, delegate: delegate)
    }
}

#Preview("No Belt Set") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    return RouterView { router in
        builder.profileView(router: router)
    }
}

// MARK: - Avatar Label

/// Value-type view so construction inside `PhotosPicker`'s `label:` closure
/// doesn't cross main-actor isolation. The body runs on the main actor at render
/// time through standard SwiftUI View conformance.
private struct AvatarLabelView: View {
    let imageURL: String?
    let localImage: UIImage?
    let userName: String
    let isUploading: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.wazaAccent.opacity(0.15))
                .frame(width: 80, height: 80)

            if let localImage {
                Image(uiImage: localImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else if let imageURL, !imageURL.isEmpty {
                ImageLoaderView(urlString: imageURL)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Text(String(userName.prefix(1)).uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.wazaAccent)
            }

            Image(systemName: "camera.fill")
                .font(.caption2)
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.wazaAccent, in: Circle())
                .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 2))
                .offset(x: 28, y: 28)

            if isUploading {
                Circle()
                    .fill(.black.opacity(0.35))
                    .frame(width: 80, height: 80)
                ProgressView()
                    .tint(.white)
            }
        }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func profileView(router: AnyRouter, delegate: ProfileDelegate = ProfileDelegate()) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showProfileView(delegate: ProfileDelegate) {
        router.showScreen(.push) { router in
            builder.profileView(router: router, delegate: delegate)
        }
    }

}
