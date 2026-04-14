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
                achievementsSection
                    .scaleAppear(delay: 0.12)
                if presenter.hasMonthlyReport {
                    monthlyReportSection
                        .scaleAppear(delay: 0.15)
                }
                trainingScheduleSection
                    .scaleAppear(delay: 0.18)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    if let image = presenter.shareCardImage {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview("My Waza Stats", image: Image(uiImage: image))
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundStyle(Color.wazaAccent)
                        }
                    }
                    settingsButton
                }
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
                .font(.title2)
                .fontWeight(.semibold)

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
    private var avatarPicker: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color.wazaAccent.opacity(0.15))
                    .frame(width: 80, height: 80)

                if let urlString = presenter.profileImageURL, !urlString.isEmpty {
                    ImageLoaderView(urlString: urlString)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Text(String(presenter.userName.prefix(1)).uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.wazaAccent)
                }

                // Small camera badge so users know the avatar is tappable
                Image(systemName: "camera.fill")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Color.wazaAccent, in: Circle())
                    .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 2))
                    .offset(x: 28, y: 28)

                if presenter.isUploadingProfileImage {
                    Circle()
                        .fill(.black.opacity(0.35))
                        .frame(width: 80, height: 80)
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .accessibilityLabel("Change profile photo")
    }

    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        presenter.onProfileImageSelected(image)
        selectedPhotoItem = nil
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
                .font(.title3)
                .fontWeight(.bold)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 44, height: 44)
                .background(Color.wazaAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievements")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(presenter.achievementsProgress + " unlocked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .anyButton(.press) {
            presenter.onAchievementsTapped()
        }
    }

    // MARK: - Monthly Report

    private var monthlyReportSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.title3)
                .foregroundStyle(Color.wazaAccent)
                .frame(width: 44, height: 44)
                .background(Color.wazaAccent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Monthly Report")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Stats and highlights from last month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .anyButton(.press) {
            presenter.onMonthlyReportTapped()
        }
    }

    // MARK: - Training Schedule

    private var trainingScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Training Schedule")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Manage")
                    .font(.caption)
                    .foregroundStyle(Color.wazaAccent)
                    .anyButton {
                        presenter.onManageScheduleTapped()
                    }
            }

            if presenter.gyms.isEmpty {
                Text("No gyms added yet. Tap Manage to set up your training schedule.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(presenter.gyms, id: \.gymId) { gym in
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.wazaAccent)
                        Text(gym.name)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                if presenter.scheduleCount > 0 {
                    Text("^[\(presenter.scheduleCount) class](inflect: true) scheduled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(Color.wazaAccent)
            .anyButton {
                presenter.onSettingsButtonPressed()
            }
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
