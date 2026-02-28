import SwiftUI

struct CheckInView: View {
    @State var presenter: CheckInPresenter
    let delegate: CheckInDelegate

    private let moodEmojis = ["😴", "😐", "🙂", "😊", "🔥"]

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
                    Button("Done") { presenter.onDismissTapped() }
                        .foregroundStyle(.secondary)
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

    // MARK: - Gym Header

    private var gymHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.accent)

            Text(presenter.gymName)
                .font(.title2)
                .fontWeight(.bold)

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
            Text("How are you feeling?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { rating in
                    Text(moodEmojis[rating - 1])
                        .font(.system(size: 36))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            presenter.selectedMood == rating
                                ? Color.accentColor.opacity(0.15)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(presenter.selectedMood == rating ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                        .anyButton {
                            presenter.onMoodSelected(rating)
                        }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Confirm CTA

    private var confirmButton: some View {
        Text("Confirm Check-In")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.accent, in: RoundedRectangle(cornerRadius: 14))
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

            Text("You're in! Great work showing up.")
                .font(.headline)
                .multilineTextAlignment(.center)

            if presenter.isStreamingAI || !presenter.aiMessage.isEmpty {
                aiEncouragementCard
            }

            logSessionButton
        }
    }

    private var aiEncouragementCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "apple.intelligence")
                    .font(.caption)
                    .foregroundStyle(.accent)
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .frame(maxWidth: .infinity)
    }

    private var logSessionButton: some View {
        Text("Log Full Session")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
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

    func showCheckInView(gym: GymLocationModel, schedule: ClassScheduleModel?, onDismiss: (() -> Void)? = nil) {
        let delegate = CheckInDelegate(gym: gym, matchedSchedule: schedule, checkInMethod: .manual)
        router.showScreen(.sheet, onDismiss: onDismiss) { router in
            builder.checkInView(router: router, delegate: delegate)
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
