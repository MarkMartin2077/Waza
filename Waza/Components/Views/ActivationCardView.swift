import SwiftUI

struct ActivationCardView: View {
    let userName: String?
    let accentColor: Color?
    let isBeltSet: Bool
    let isGymSet: Bool
    let onLogSessionTapped: (() -> Void)?
    let onSetBeltTapped: (() -> Void)?

    private var resolvedAccent: Color {
        accentColor ?? .accentColor
    }

    private var showQuickSetup: Bool {
        !isBeltSet || !isGymSet
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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
                if !isBeltSet {
                    setupChip(
                        label: "Set your belt",
                        isDone: false,
                        onTap: onSetBeltTapped
                    )
                } else {
                    setupChip(
                        label: "Belt set",
                        isDone: true,
                        onTap: nil
                    )
                }

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

#Preview("Full name, nothing set") {
    ActivationCardView(
        userName: "Marcus",
        accentColor: .blue,
        isBeltSet: false,
        isGymSet: false,
        onLogSessionTapped: { },
        onSetBeltTapped: { }
    )
    .padding()
}

#Preview("No name, belt set") {
    ActivationCardView(
        userName: nil,
        accentColor: .purple,
        isBeltSet: true,
        isGymSet: false,
        onLogSessionTapped: { },
        onSetBeltTapped: nil
    )
    .padding()
}

#Preview("Everything set, no chips") {
    ActivationCardView(
        userName: "Alex",
        accentColor: .brown,
        isBeltSet: true,
        isGymSet: true,
        onLogSessionTapped: { },
        onSetBeltTapped: nil
    )
    .padding()
}

#Preview("Compact, default accent") {
    ActivationCardView(
        userName: nil,
        accentColor: nil,
        isBeltSet: false,
        isGymSet: true,
        onLogSessionTapped: nil,
        onSetBeltTapped: nil
    )
    .padding()
}
