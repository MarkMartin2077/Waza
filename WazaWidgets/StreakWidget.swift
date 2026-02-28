import WidgetKit
import SwiftUI

// MARK: - Timeline

struct StreakEntry: TimelineEntry {
    let date: Date
    let data: WazaWidgetData
}

struct StreakTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: .now, data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: .now, data: .load())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

// MARK: - Widget

struct StreakWidget: Widget {
    let kind = "WazaStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(entry.data.accentColor.opacity(0.08), for: .widget)
        }
        .configurationDisplayName("Training Streak")
        .description("Your current BJJ training streak.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Views

struct StreakWidgetView: View {
    let entry: StreakEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(spacing: 4) {
            Spacer()

            Text("\(entry.data.streakCount)")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .foregroundStyle(entry.data.accentColor)
                .minimumScaleFactor(0.6)

            Text("DAY STREAK")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Spacer()

            Text(entry.data.beltDisplayName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var mediumView: some View {
        HStack(spacing: 0) {
            // Left — streak
            VStack(spacing: 4) {
                Text("\(entry.data.streakCount)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(entry.data.accentColor)
                    .minimumScaleFactor(0.6)
                Text("DAY STREAK")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 48)

            // Right — sessions this week
            VStack(spacing: 4) {
                Text("\(entry.data.sessionsThisWeek)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(entry.data.accentColor)
                    .minimumScaleFactor(0.6)
                Text("THIS WEEK")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .overlay(alignment: .bottom) {
            Text(entry.data.beltDisplayName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
        }
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, data: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    StreakWidget()
} timeline: {
    StreakEntry(date: .now, data: .placeholder)
}
