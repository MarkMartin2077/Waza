import SwiftUI

struct CheckInView: View {
    @State var presenter: CheckInPresenter
    let delegate: CheckInDelegate

    private let moodEmojis = Mood.emojis
    private let moodLabels = Mood.labels
    @State private var celebrationOpacity: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    gymHeader
                    if !presenter.isConfirmed {
                        moodSection
                        confirmButton
                    } else {
                        confirmedState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Button required by SwiftUI ToolbarItem API
                    Button("Done") { presenter.onDismissTapped() }
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                presenter.onViewAppear()
            }
        }
        .overlay(alignment: .center) {
            Color.wazaAccent
                .opacity(celebrationOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onChange(of: presenter.isConfirmed) { _, isConfirmed in
            guard isConfirmed else { return }
            withAnimation(.easeOut(duration: 0.3)) { celebrationOpacity = 0.6 }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) { celebrationOpacity = 0 }
        }
    }

    // MARK: - Gym Header

    private var gymHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.wazaAccent)

            Text(presenter.gymName)
                .font(.wazaDisplayMedium)

            if let className = presenter.scheduleName {
                Text(className)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Mood

    private var moodSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                Text("How are you feeling?")
                    .font(.headline)
                Text("(optional)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    let isSelected = presenter.selectedMood == rating
                    VStack(spacing: 4) {
                        Text(moodEmojis[rating - 1])
                            .font(.system(size: 36))
                        Text(moodLabels[rating - 1])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        isSelected
                            ? Color.wazaAccent.opacity(0.15)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.wazaAccent : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    .accessibilityLabel("\(moodLabels[rating - 1]), mood \(rating) of 5")
                    .anyButton {
                        presenter.onMoodSelected(rating)
                    }
                }
            }
        }
        .padding(16)
        .wazaCard()
    }

    // MARK: - Confirm CTA

    private var confirmButton: some View {
        Text("Confirm Check-In")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.wazaAccent, in: RoundedRectangle(cornerRadius: 14))
            .anyButton(.press) {
                presenter.onConfirmTapped()
            }
    }

    // MARK: - Confirmed State

    private var confirmedState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .scaleAppear(delay: 0)

            Text("You're in! Great work showing up.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .scaleAppear(delay: 0.1)

            if presenter.isStreamingAI || !presenter.aiMessage.isEmpty {
                aiEncouragementCard
                    .scaleAppear(delay: 0.2)
            }

            logSessionButton
                .scaleAppear(delay: 0.25)
        }
    }

    private var aiEncouragementCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "apple.intelligence")
                    .font(.caption)
                    .foregroundStyle(Color.wazaAccent)
                Text("Coach says…")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            if presenter.aiMessage.isEmpty && presenter.isStreamingAI {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Generating encouragement…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(presenter.aiMessage)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .wazaCard()
        .frame(maxWidth: .infinity)
    }

    private var logSessionButton: some View {
        Text("Log Full Session")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(Color.wazaAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.wazaAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .anyButton(.press) {
                presenter.onLogSessionTapped()
            }
    }
}

// MARK: - Builder Extension

extension CoreBuilder {

    func checkInView(router: AnyRouter, delegate: CheckInDelegate) -> some View {
        CheckInView(
            presenter: CheckInPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, checkInMethod: CheckInMethod = .manual, onDismiss: (() -> Void)? = nil) {
        let delegate = CheckInDelegate(gym: gym, matchedSchedule: schedule, checkInMethod: checkInMethod)
        router.showScreen(.sheet, onDismiss: onDismiss) { router in
            builder.checkInView(router: router, delegate: delegate)
        }
    }

    func showSessionEntryView(attendanceRecord: ClassAttendanceModel? = nil, onDismiss: (() -> Void)? = nil) {
        let interactor = builder.interactor
        let delegate = SessionEntryDelegate(
            onSessionSaved: attendanceRecord != nil ? { session in
                guard var record = attendanceRecord else { return }
                record.linkedSessionId = session.id
                try? interactor.updateAttendance(record)
            } : nil
        )
        router.showScreen(.sheet, onDismiss: onDismiss) { router in
            builder.sessionEntryView(router: router, delegate: delegate)
        }
    }

}

// MARK: - Preview

#Preview("Check In") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CheckInDelegate(gym: .mock, matchedSchedule: .mock)

    return RouterView { router in
        builder.checkInView(router: router, delegate: delegate)
    }
}

#Preview("Check In - Confirmed") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CheckInDelegate(gym: .mock, matchedSchedule: nil)

    return RouterView { router in
        builder.checkInView(router: router, delegate: delegate)
    }
}
