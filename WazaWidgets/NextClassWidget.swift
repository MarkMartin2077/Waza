import WidgetKit
import SwiftUI

// MARK: - Timeline

struct NextClassEntry: TimelineEntry {
    let date: Date
    let data: WazaWidgetData
}

struct NextClassTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> NextClassEntry {
        NextClassEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (NextClassEntry) -> Void) {
        completion(NextClassEntry(date: .now, data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextClassEntry>) -> Void) {
        let entry = NextClassEntry(date: .now, data: .load())
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

// MARK: - Widget

struct NextClassWidget: Widget {
    let kind = "WazaNextClassWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextClassTimelineProvider()) { entry in
            NextClassWidgetView(entry: entry)
                .containerBackground(entry.data.accentColor.opacity(0.08), for: .widget)
        }
        .configurationDisplayName("Next Class")
        .description("Your next scheduled BJJ class.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Views

struct NextClassWidgetView: View {
    let entry: NextClassEntry
    @Environment(\.widgetFamily) private var family

    var hasClass: Bool { entry.data.nextClassTypeDisplayName != nil }

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("NEXT CLASS")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(entry.data.accentColor)

            Spacer()

            if hasClass {
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.data.nextClassTypeDisplayName ?? "")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    if let time = entry.data.nextClassTimeString {
                        Text(time)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    }

                    if let gym = entry.data.nextClassGymName {
                        Text(gym)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            } else {
                Text("No class\nscheduled")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var mediumView: some View {
        HStack(alignment: .center, spacing: 20) {
            // Belt accent bar
            RoundedRectangle(cornerRadius: 3)
                .fill(entry.data.accentColor)
                .frame(width: 4)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT CLASS")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(entry.data.accentColor)

                if hasClass {
                    Text(entry.data.nextClassTypeDisplayName ?? "")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    if let time = entry.data.nextClassTimeString {
                        Text(time)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    }

                    if let gym = entry.data.nextClassGymName {
                        Text(gym)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No class scheduled")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    NextClassWidget()
} timeline: {
    NextClassEntry(date: .now, data: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    NextClassWidget()
} timeline: {
    NextClassEntry(date: .now, data: .placeholder)
}

#Preview("No class - Small", as: .systemSmall) {
    NextClassWidget()
} timeline: {
    NextClassEntry(date: .now, data: WazaWidgetData(
        streakCount: 3,
        accentColorHex: "6366F1",
        beltDisplayName: "Brown Belt",
        sessionsThisWeek: 1,
        nextClassTypeDisplayName: nil,
        nextClassGymName: nil,
        nextClassDayOfWeek: nil,
        nextClassStartHour: nil,
        nextClassStartMinute: nil
    ))
}
