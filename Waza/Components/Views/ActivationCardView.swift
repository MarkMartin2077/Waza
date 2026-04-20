import SwiftUI

struct ActivationCardView: View {
    let userName: String?
    let accentColor: Color?
    let isGymSet: Bool
    let onLogSessionTapped: (() -> Void)?

    private var resolvedAccent: Color {
        accentColor ?? .accentColor
    }

    private var showQuickSetup: Bool {
        !isGymSet
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerText
            ctaButton
            if showQuickSetup {
                quickSetupSection
            }
        }
        .padding(20)
        .wazaCard()
    }

    // MARK: - Header

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let userName {
                Text("Welcome to Waza, \(userName).")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Welcome to Waza.")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text("Start logging sessions to track your progress.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Text("Log Your First Session")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(resolvedAccent, in: RoundedRectangle(cornerRadius: 14))
            .anyButton(.press) {
                onLogSessionTapped?()
            }
    }

    // MARK: - Quick Setup

    private var quickSetupSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Setup")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                if !isGymSet {
                    setupChip(
                        label: "Add a gym",
                        isDone: false,
                        onTap: nil
                    )
                } else {
                    setupChip(
                        label: "Gym added",
                        isDone: true,
                        onTap: nil
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func setupChip(label: String, isDone: Bool, onTap: (() -> Void)?) -> some View {
        HStack(spacing: 4) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(isDone ? resolvedAccent : .secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(isDone ? .primary : .secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isDone ? resolvedAccent.opacity(0.1) : Color.secondary.opacity(0.1), in: Capsule())
        .anyButton(.press) {
            onTap?()
        }
    }
}

// MARK: - Previews

#Preview("New user, no gym") {
    ActivationCardView(
        userName: "Marcus",
        accentColor: Color.wazaAccent,
        isGymSet: false,
        onLogSessionTapped: { }
    )
    .padding()
}

#Preview("Gym added") {
    ActivationCardView(
        userName: "Alex",
        accentColor: Color.wazaAccent,
        isGymSet: true,
        onLogSessionTapped: { }
    )
    .padding()
}
