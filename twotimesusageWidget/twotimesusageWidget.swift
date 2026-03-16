import WidgetKit
import SwiftUI

// MARK: - Usage Status Logic

enum UsageStatus {
    case doubleUsage
    case normalUsage

    /// Peak hours are weekdays 12:00–18:00 UTC (= 5–11am PT / 12–6pm GMT).
    /// Outside peak hours and all weekends = 2x usage.
    static func current(at date: Date = .now) -> UsageStatus {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let weekday = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)

        let isWeekend = weekday == 1 || weekday == 7
        if isWeekend { return .doubleUsage }

        let isPeakHour = hour >= 12 && hour < 18
        return isPeakHour ? .normalUsage : .doubleUsage
    }

    var label: String {
        switch self {
        case .doubleUsage: "2x Usage"
        case .normalUsage: "Normal Usage"
        }
    }

    var subtitle: String {
        switch self {
        case .doubleUsage: "Double usage active"
        case .normalUsage: "Peak hours"
        }
    }

    var colour: Color {
        switch self {
        case .doubleUsage: Color(red: 0.18, green: 0.74, blue: 0.42)
        case .normalUsage: Color(red: 0.85, green: 0.47, blue: 0.34)
        }
    }
}

// MARK: - Timeline

struct UsageEntry: TimelineEntry {
    let date: Date
    let status: UsageStatus
}

struct UsageTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> UsageEntry {
        UsageEntry(date: .now, status: .current())
    }

    func getSnapshot(in context: Context, completion: @escaping (UsageEntry) -> Void) {
        completion(UsageEntry(date: .now, status: .current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UsageEntry>) -> Void) {
        var entries: [UsageEntry] = []
        let now = Date()

        // Generate entries for the next 24 hours at each UTC boundary hour that matters
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        // Start with current entry
        entries.append(UsageEntry(date: now, status: .current(at: now)))

        // Add entries at each transition point (12:00 UTC and 18:00 UTC) and midnight for weekday changes
        let transitionHours = [0, 12, 18]
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)

        for dayOffset in 0...1 {
            for hour in transitionHours {
                var components = currentComponents
                components.hour = hour
                components.minute = 0
                components.second = 0
                if let candidate = calendar.date(from: components) {
                    let adjusted = calendar.date(byAdding: .day, value: dayOffset, to: candidate)!
                    if adjusted > now {
                        entries.append(UsageEntry(date: adjusted, status: .current(at: adjusted)))
                    }
                }
            }
        }

        entries.sort { $0.date < $1.date }

        let timeline = Timeline(entries: entries, policy: .after(
            calendar.date(byAdding: .hour, value: 24, to: now)!
        ))
        completion(timeline)
    }
}

// MARK: - Pixel Art Claude Mascot

struct ClaudeMascot: View {
    let pixelSize: CGFloat

    private let body_ = Color(red: 0.80, green: 0.55, blue: 0.40)
    private let eye_ = Color(red: 0.15, green: 0.12, blue: 0.10)

    // 10 columns x 10 rows grid
    // 0 = empty, 1 = body, 2 = eye
    private let grid: [[Int]] = [
        [0,1,1,1,1,1,1,1,1,0],  // row 0: head top
        [0,1,1,1,1,1,1,1,1,0],  // row 1: head
        [0,1,1,1,1,1,1,1,1,0],  // row 2: head
        [1,1,1,1,1,1,1,1,1,1],  // row 3: ears
        [1,1,1,2,1,1,2,1,1,1],  // row 4: ears + eyes
        [0,1,1,1,1,1,1,1,1,0],  // row 5: body
        [0,1,1,1,1,1,1,1,1,0],  // row 6: body
        [0,1,1,1,1,1,1,1,1,0],  // row 7: body
        [0,1,1,0,0,0,0,1,1,0],  // row 8: legs
        [0,1,1,0,0,0,0,1,1,0],  // row 9: legs
    ]

    var body: some View {
        Canvas { context, _ in
            let p = pixelSize
            for (row, cols) in grid.enumerated() {
                for (col, val) in cols.enumerated() {
                    guard val != 0 else { continue }
                    let colour = val == 2 ? eye_ : body_
                    let rect = CGRect(x: CGFloat(col) * p, y: CGFloat(row) * p, width: p, height: p)
                    context.fill(Path(rect), with: .color(colour))
                }
            }
        }
        .frame(width: pixelSize * 10, height: pixelSize * 10)
    }
}

// MARK: - Shared Helpers

func nextChangeDescription(at date: Date) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!

    let weekday = calendar.component(.weekday, from: date)
    let hour = calendar.component(.hour, from: date)
    let isWeekend = weekday == 1 || weekday == 7

    func timeUntil(from: Date, to: Date) -> String {
        let interval = to.timeIntervalSince(from)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    if isWeekend {
        let daysUntilMonday = weekday == 7 ? 2 : 1
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12; components.minute = 0
        if let base = calendar.date(from: components) {
            let target = calendar.date(byAdding: .day, value: daysUntilMonday, to: base)!
            return timeUntil(from: date, to: target)
        }
    } else if hour >= 12 && hour < 18 {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 18; components.minute = 0
        if let target = calendar.date(from: components) {
            return timeUntil(from: date, to: target)
        }
    } else if hour < 12 {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12; components.minute = 0
        if let target = calendar.date(from: components) {
            return timeUntil(from: date, to: target)
        }
    } else {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
        let tomorrowWeekday = calendar.component(.weekday, from: tomorrow)
        if tomorrowWeekday == 1 || tomorrowWeekday == 7 {
            let daysUntilMonday = tomorrowWeekday == 7 ? 3 : 2
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 12; components.minute = 0
            if let base = calendar.date(from: components) {
                let target = calendar.date(byAdding: .day, value: daysUntilMonday, to: base)!
                return timeUntil(from: date, to: target)
            }
        } else {
            var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            components.hour = 12; components.minute = 0
            if let target = calendar.date(from: components) {
                return timeUntil(from: date, to: target)
            }
        }
    }
    return ""
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    let entry: UsageEntry

    var body: some View {
        ZStack {
            Rectangle().fill(entry.status.colour.gradient)

            VStack(spacing: 4) {
                HStack {
                    Text("Claude")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                    Spacer()
                }

                Spacer()

                ClaudeMascot(pixelSize: 4)
                    .opacity(0.5)

                Spacer()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.status.label)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        HStack(spacing: 4) {
                            Text("Changes in")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                            Text(nextChangeDescription(at: entry.date))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                    }
                    Spacer()
                }
            }
            .padding(14)
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: UsageEntry

    var body: some View {
        ZStack {
            Rectangle().fill(entry.status.colour.gradient)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Claude")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))

                    Spacer()

                    Text(entry.status.label)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 4) {
                        Text("Changes in")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                        Text(nextChangeDescription(at: entry.date))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }

                Spacer()

                ClaudeMascot(pixelSize: 5)
                    .opacity(0.5)
            }
            .padding(14)
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: UsageEntry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Definition

struct TwoTimesUsageWidget: Widget {
    let kind = "twotimesusageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UsageTimelineProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Claude Usage")
        .description("Shows whether Claude is currently offering 2x usage.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Widget Bundle

@main
struct TwoTimesUsageWidgetBundle: WidgetBundle {
    var body: some Widget {
        TwoTimesUsageWidget()
    }
}

// MARK: - Previews

#Preview("Small - 2x", as: .systemSmall) {
    TwoTimesUsageWidget()
} timeline: {
    UsageEntry(date: .now, status: .doubleUsage)
}

#Preview("Small - Normal", as: .systemSmall) {
    TwoTimesUsageWidget()
} timeline: {
    UsageEntry(date: .now, status: .normalUsage)
}

#Preview("Medium - 2x", as: .systemMedium) {
    TwoTimesUsageWidget()
} timeline: {
    UsageEntry(date: .now, status: .doubleUsage)
}
