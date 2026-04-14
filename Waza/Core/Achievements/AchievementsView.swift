import SwiftUI
import SwiftfulRouting

struct AchievementsView: View {
    @State var presenter: AchievementsPresenter

    var body: some View {
        List {
            ForEach(presenter.sections, id: \.category) { section in
                Section {
                    ForEach(Array(section.achievements.enumerated()), id: \.element) { index, achievementId in
                        AchievementRowView(
                            achievementId: achievementId,
                            isEarned: presenter.isEarned(achievementId),
                            earnedDate: presenter.earnedDate(for: achievementId),
                            onTap: { presenter.onAchievementTapped(achievementId) }
                        )
                        .staggeredAppear(index: index)
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                } header: {
                    Label(section.category.displayName, systemImage: section.category.iconName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.bottom, 24, for: .scrollContent)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            presenter.onViewAppear()
        }
    }

}

// MARK: - Achievement Detail Sheet

struct AchievementDetailSheetView: View {
    let achievementId: AchievementId
    let isEarned: Bool
    let earnedDate: Date?
    let progressHint: String?

    private var rarityColor: Color { achievementId.rarity.color }

    var body: some View {
        VStack(spacing: 28) {
            detailIcon
            detailInfo
            detailStatus
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    private var detailIcon: some View {
        ZStack {
            Circle().fill(rarityColor.opacity(0.05)).frame(width: 130, height: 130)
            Circle().fill(rarityColor.opacity(0.10)).frame(width: 108, height: 108)
            Circle()
                .fill(rarityColor.opacity(0.15))
                .frame(width: 86, height: 86)
                .overlay(Circle().stroke(rarityColor.opacity(0.35), lineWidth: 1.5))
            Image(systemName: isEarned ? achievementId.iconName : "lock.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(isEarned ? rarityColor : .secondary)
        }
        .opacity(isEarned ? 1 : 0.55)
    }

    private var detailInfo: some View {
        VStack(spacing: 10) {
            Text(achievementId.displayName)
                .font(.wazaTitle)
                .multilineTextAlignment(.center)
            Label(achievementId.rarity.displayName, systemImage: achievementId.rarity.symbolName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isEarned ? rarityColor : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((isEarned ? rarityColor : Color.secondary).opacity(0.12), in: Capsule())
            Text(achievementId.achievementDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var detailStatus: some View {
        if let earnedDate {
            Label(earnedDate.formatted(date: .long, time: .omitted), systemImage: "checkmark.seal.fill")
                .font(.caption)
                .foregroundStyle(.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.green.opacity(0.1), in: Capsule())
        } else {
            VStack(spacing: 10) {
                Label("Not yet earned", systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6), in: Capsule())

                if let progressHint {
                    Text(progressHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - CoreRouter Extension

extension CoreRouter {

    func showAchievementDetail(achievementId: AchievementId, isEarned: Bool, earnedDate: Date?, progressHint: String?) {
        let config = ResizableSheetConfig(detents: [.medium], selection: nil, dragIndicator: .visible)
        router.showScreen(.sheetConfig(config: config)) { _ in
            AchievementDetailSheetView(
                achievementId: achievementId,
                isEarned: isEarned,
                earnedDate: earnedDate,
                progressHint: progressHint
            )
        }
    }

}

// MARK: - CoreBuilder Extension

extension CoreBuilder {

    func achievementsView(router: AnyRouter) -> some View {
        AchievementsView(
            presenter: AchievementsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

}

// MARK: - Preview

#Preview("Achievements") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        NavigationStack {
            builder.achievementsView(router: router)
        }
    }
}

#Preview("Achievements - No Earned") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    return RouterView { router in
        NavigationStack {
            builder.achievementsView(router: router)
        }
    }
}
