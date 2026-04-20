import SwiftUI

struct WeeklyAttendanceRingView: View {
    let current: Int?
    let target: Int?

    private var progress: Double {
        guard let currentCount = current, let targetCount = target, targetCount > 0 else { return 0 }
        return min(Double(currentCount) / Double(targetCount), 1.0)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.wazaAccent.opacity(0.15), lineWidth: 6)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.wazaAccent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)

                if let currentCount = current {
                    Text("\(currentCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("This Week")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let currentCount = current, let targetCount = target {
                    Text("\(currentCount) of \(targetCount) classes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(14)
        .wazaCard()
    }
}

#Preview("Partial Progress") {
    WeeklyAttendanceRingView(current: 2, target: 4)
        .padding()
}

#Preview("Full") {
    WeeklyAttendanceRingView(current: 4, target: 4)
        .padding()
}

#Preview("Empty") {
    WeeklyAttendanceRingView(current: 0, target: 3)
        .padding()
}

#Preview("No Data") {
    WeeklyAttendanceRingView(current: nil, target: nil)
        .padding()
}
