import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Attributes
// Intentionally duplicated from Waza/Managers/LiveActivity/TrainingTimerAttributes.swift.
// Both targets encode/decode to the same format — must stay in sync.

struct TrainingTimerAttributes: ActivityAttributes {

    struct ContentState: Codable, Hashable { }

    let sessionTypeDisplayName: String
    let gymName: String?
    let beltAccentColorHex: String
    let startDate: Date

    var accentColor: Color {
        Color(hex: beltAccentColorHex)
    }
}

// MARK: - Widget

struct TrainingTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TrainingTimerAttributes.self) { context in
            TrainingTimerLockScreenView(context: context)
                .padding(16)
                .containerBackground(context.attributes.accentColor.opacity(0.08), for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 10) {
                        Image(systemName: "figure.wrestling")
                            .font(.title2)
                            .foregroundStyle(context.attributes.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.sessionTypeDisplayName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            if let gymName = context.attributes.gymName {
                                Text(gymName)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.attributes.startDate, style: .timer)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(context.attributes.accentColor)
                            .monospacedDigit()
                        Text("ELAPSED")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 4)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "figure.wrestling")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(context.attributes.accentColor)
                    Text(context.attributes.sessionTypeDisplayName)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(context.attributes.accentColor)
                        .lineLimit(1)
                }
            } compactTrailing: {
                Text(context.attributes.startDate, style: .timer)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(context.attributes.accentColor)
            } minimal: {
                Image(systemName: "figure.wrestling")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(context.attributes.accentColor)
            }
        }
    }
}

// MARK: - Lock Screen View

private struct TrainingTimerLockScreenView: View {
    let context: ActivityViewContext<TrainingTimerAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Belt-tinted icon
            Image(systemName: "figure.wrestling")
                .font(.title)
                .foregroundStyle(context.attributes.accentColor)
                .frame(width: 48, height: 48)
                .background(
                    context.attributes.accentColor.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 14)
                )

            // Session info
            VStack(alignment: .leading, spacing: 3) {
                Text(context.attributes.sessionTypeDisplayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                if let gymName = context.attributes.gymName {
                    Text(gymName)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Text("TRAINING IN PROGRESS")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(context.attributes.accentColor)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Elapsed timer
            VStack(alignment: .trailing, spacing: 2) {
                Text(context.attributes.startDate, style: .timer)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(context.attributes.accentColor)
                    .monospacedDigit()
                Text("elapsed")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
