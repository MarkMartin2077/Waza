import SwiftUI

struct ProfileDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ProfileView: View {

    @State var presenter: ProfilePresenter
    let delegate: ProfileDelegate

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                statsSection
                beltHistorySection
                achievementsSection
                trainingScheduleSection
                AttendanceCalendarView(attendance: presenter.classAttendance)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                settingsButton
            }
        }
        .sheet(isPresented: $presenter.showAddPromotionSheet) {
            addPromotionSheet
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
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: presenter.currentBelt?.belt.colorHex ?? BJJBelt.white.colorHex).opacity(0.15))
                    .frame(width: 80, height: 80)
                Text(String(presenter.beltDisplayName.prefix(1)).uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: presenter.currentBelt?.belt.colorHex ?? BJJBelt.white.colorHex))
            }

            Text(presenter.userName)
                .font(.title2)
                .fontWeight(.semibold)

            Text(presenter.beltDisplayName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

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

    // MARK: - Stats

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            profileStat(value: "\(presenter.sessionStats.totalSessions)", label: "Sessions")
            profileStat(value: "\(presenter.sessionStats.thisWeekSessions)", label: "This Week")
            profileStat(value: presenter.totalTrainingHoursText, label: "Hrs Trained")
        }
    }

    private func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Belt History

    private var beltHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Belt History")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    presenter.onAddPromotionTapped()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.headline)
                        .foregroundStyle(.accent)
                }
            }

            if presenter.beltHistory.isEmpty {
                VStack(spacing: 8) {
                    Text("No belt history recorded yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Set your current belt") {
                        presenter.onSetCurrentBeltTapped()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            } else {
                ForEach(presenter.beltHistory, id: \.id) { record in
                    beltHistoryRow(record: record)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func beltHistoryRow(record: BeltRecordModel) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: record.belt.colorHex))
                .frame(width: 12, height: 12)
            VStack(alignment: .leading, spacing: 2) {
                Text(record.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(record.promotionDateFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.title3)
                .foregroundStyle(presenter.beltAccentColor)
                .frame(width: 44, height: 44)
                .background(presenter.beltAccentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

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

    // MARK: - Training Schedule

    private var trainingScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Training Schedule")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Manage")
                    .font(.caption)
                    .foregroundStyle(.accent)
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
                            .foregroundStyle(.accent)
                        Text(gym.name)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                if presenter.scheduleCount > 0 {
                    Text("\(presenter.scheduleCount) class\(presenter.scheduleCount == 1 ? "" : "es") scheduled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Add Promotion Sheet

    private var addPromotionSheet: some View {
        NavigationStack {
            Form {
                Section("Belt") {
                    Picker("Belt", selection: $presenter.newBelt) {
                        ForEach(BJJBelt.allCases, id: \.self) { belt in
                            Text(belt.displayName).tag(belt)
                        }
                    }
                    Stepper("Stripes: \(presenter.newStripes)", value: $presenter.newStripes, in: 0...4)
                }
                Section("Date & Location") {
                    DatePicker("Promotion Date", selection: $presenter.newPromotionDate, displayedComponents: .date)
                    TextField("Academy (optional)", text: $presenter.newAcademy)
                    TextField("Notes (optional)", text: $presenter.newPromotionNotes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle(presenter.sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { presenter.onCancelPromotion() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { presenter.onSavePromotion() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                presenter.onSettingsButtonPressed()
            }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProfileDelegate()

    return RouterView { router in
        builder.profileView(router: router, delegate: delegate)
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
