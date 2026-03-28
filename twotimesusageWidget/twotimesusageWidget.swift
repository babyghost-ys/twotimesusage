import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Usage Status Logic

enum UsageStatus {
    case doubleUsage
    case normalUsage

    /// Peak hours are weekdays 12:00–18:00 UTC (= 5–11am PT / 12–6pm GMT).
    /// Outside peak hours and all weekends = 2x usage.
    /// Promotion runs until end of 2026-03-28 UTC (last day inclusive).
    private static let utc = TimeZone(identifier: "UTC") ?? .gmt

    static let promotionEnd: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        guard let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 29, hour: 0, minute: 0, second: 0)) else {
            return .distantFuture
        }
        return date
    }()

    static var hasPromotionEnded: Bool {
        Date() >= promotionEnd
    }

    static func current(at date: Date = .now) -> UsageStatus {
        if date >= promotionEnd { return .normalUsage }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc

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
        case .normalUsage: Self.hasPromotionEnded ? "Normal" : "Peak Hours"
        }
    }

    var subtitle: String {
        switch self {
        case .doubleUsage: "Double usage active"
        case .normalUsage: Self.hasPromotionEnded ? "Normal usage" : "Peak hours"
        }
    }

    var backgroundGradient: LinearGradient {
        if Self.hasPromotionEnded {
            return LinearGradient(
                colors: [Color(red: 0.96, green: 0.94, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        switch self {
        case .doubleUsage:
            return LinearGradient(
                colors: [
                    Color(red: 0.83, green: 0.27, blue: 0.17),
                    Color(red: 0.91, green: 0.52, blue: 0.17),
                    Color(red: 0.91, green: 0.77, blue: 0.17),
                    Color(red: 0.36, green: 0.67, blue: 0.29),
                    Color(red: 0.29, green: 0.56, blue: 0.80),
                    Color(red: 0.48, green: 0.37, blue: 0.65),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .normalUsage:
            return LinearGradient(
                colors: [Color(red: 0.85, green: 0.47, blue: 0.34)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var isDouble: Bool { self == .doubleUsage }
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
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt

        // Start with current entry
        entries.append(UsageEntry(date: now, status: .current(at: now)))

        // Add entries every 15 minutes for the next 2 hours so the countdown stays fresh
        for minuteOffset in stride(from: 15, through: 120, by: 15) {
            if let future = calendar.date(byAdding: .minute, value: minuteOffset, to: now) {
                entries.append(UsageEntry(date: future, status: .current(at: future)))
            }
        }

        // Add entries at each transition point (12:00 UTC and 18:00 UTC) and midnight for weekday changes
        let transitionHours = [0, 12, 18]
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)

        for dayOffset in 0...1 {
            for hour in transitionHours {
                var components = currentComponents
                components.hour = hour
                components.minute = 0
                components.second = 0
                if let candidate = calendar.date(from: components),
                   let adjusted = calendar.date(byAdding: .day, value: dayOffset, to: candidate),
                   adjusted > now {
                    entries.append(UsageEntry(date: adjusted, status: .current(at: adjusted)))
                }
            }
        }

        // Add an entry at promotion end so the widget updates immediately
        let promotionEnd = UsageStatus.promotionEnd
        if promotionEnd > now {
            entries.append(UsageEntry(date: promotionEnd, status: .current(at: promotionEnd)))
        }

        entries.sort { $0.date < $1.date }

        let refreshDate = calendar.date(byAdding: .hour, value: 2, to: now) ?? now.addingTimeInterval(7200)
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
}

// MARK: - Claude Mascot (SVG Path)

struct ClaudeMascot: View {
    let size: CGFloat
    var isPeakHours: Bool = false
    var isPromotionEnded: Bool = false

    private let bodyColour = Color(red: 0.80, green: 0.55, blue: 0.40)
    private let eyeColour = Color(red: 0.15, green: 0.12, blue: 0.10)

    private var scaleFactor: CGFloat { size / 14 }

    var body: some View {
        Canvas { context, _ in
            let s = scaleFactor

            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: 1 * s, y: 0))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 0))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 3 * s))
            bodyPath.addLine(to: CGPoint(x: 14 * s, y: 3 * s))
            bodyPath.addLine(to: CGPoint(x: 14 * s, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 11 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 11 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 10 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 10 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 8 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 8 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 6 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 6 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 4 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 4 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 3 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 3 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 0, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 0, y: 3 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 3 * s))
            bodyPath.closeSubpath()

            context.fill(bodyPath, with: .color(bodyColour))

            if isPromotionEnded {
                // Dot eyes: calm, content
                let dotRadius: CGFloat = 0.55 * s
                let leftDot = Path(ellipseIn: CGRect(
                    x: 4.0 * s - dotRadius, y: 4.5 * s - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                ))
                let rightDot = Path(ellipseIn: CGRect(
                    x: 10.0 * s - dotRadius, y: 4.5 * s - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                ))
                context.fill(leftDot, with: .color(eyeColour))
                context.fill(rightDot, with: .color(eyeColour))
            } else if isPeakHours {
                let eyeStroke: CGFloat = 0.7 * s
                var leftEye = Path()
                leftEye.move(to: CGPoint(x: 3.0 * s, y: 4.5 * s))
                leftEye.addLine(to: CGPoint(x: 5.0 * s, y: 4.5 * s))
                var rightEye = Path()
                rightEye.move(to: CGPoint(x: 9.0 * s, y: 4.5 * s))
                rightEye.addLine(to: CGPoint(x: 11.0 * s, y: 4.5 * s))
                context.stroke(leftEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
                context.stroke(rightEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
            } else {
                let eyeStroke: CGFloat = 0.7 * s
                var leftEye = Path()
                leftEye.move(to: CGPoint(x: 3.5 * s, y: 3.8 * s))
                leftEye.addLine(to: CGPoint(x: 4.5 * s, y: 4.5 * s))
                leftEye.addLine(to: CGPoint(x: 3.5 * s, y: 5.2 * s))
                var rightEye = Path()
                rightEye.move(to: CGPoint(x: 10.5 * s, y: 3.8 * s))
                rightEye.addLine(to: CGPoint(x: 9.5 * s, y: 4.5 * s))
                rightEye.addLine(to: CGPoint(x: 10.5 * s, y: 5.2 * s))
                context.stroke(leftEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
                context.stroke(rightEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
            }
        }
        .frame(width: size, height: size / 14 * 11)
    }
}

// MARK: - Shared Helpers

func nextChangeDescription(at date: Date) -> String {
    let promotionEnd = UsageStatus.promotionEnd

    // After promotion ends, no more transitions
    if date >= promotionEnd { return "Ended" }

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt

    let weekday = calendar.component(.weekday, from: date)
    let hour = calendar.component(.hour, from: date)
    let isWeekend = weekday == 1 || weekday == 7

    func timeUntil(from: Date, to: Date) -> String {
        let target = min(to, promotionEnd)
        let interval = target.timeIntervalSince(from)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    if isWeekend {
        let daysUntilMonday = weekday == 7 ? 2 : 1
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12; components.minute = 0
        if let base = calendar.date(from: components),
           let target = calendar.date(byAdding: .day, value: daysUntilMonday, to: base) {
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
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else { return "" }
        let tomorrowWeekday = calendar.component(.weekday, from: tomorrow)
        if tomorrowWeekday == 1 || tomorrowWeekday == 7 {
            let daysUntilMonday = tomorrowWeekday == 7 ? 3 : 2
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 12; components.minute = 0
            if let base = calendar.date(from: components),
               let target = calendar.date(byAdding: .day, value: daysUntilMonday, to: base) {
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

// MARK: - Refresh Intent

struct RefreshUsageIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Usage"
    static var description: IntentDescription = "Refreshes the usage widget"

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Widget Views

struct SmallWidgetView: View {
    @Environment(\.colorScheme) private var colorScheme
    let entry: UsageEntry

    private var ended: Bool { UsageStatus.hasPromotionEnded }

    private var background: AnyShapeStyle {
        if ended {
            return AnyShapeStyle(colorScheme == .dark
                ? Color(red: 0.10, green: 0.09, blue: 0.08)
                : Color(red: 0.96, green: 0.94, blue: 0.90))
        }
        return entry.status.isDouble
            ? AnyShapeStyle(entry.status.backgroundGradient)
            : AnyShapeStyle(colorScheme == .dark ? Color.black : Color.white)
    }

    private var primaryText: Color {
        ended ? Color(red: 0.15, green: 0.12, blue: 0.10) : (entry.status.isDouble ? .white : .primary)
    }

    var body: some View {
        ZStack {
            Rectangle().fill(background)

            VStack(spacing: 4) {
                HStack {
                    Text("Claude")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(primaryText.opacity(0.85))
                    Spacer()
                    Button(intent: RefreshUsageIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(primaryText.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                ClaudeMascot(size: 56, isPeakHours: !entry.status.isDouble && !ended, isPromotionEnded: ended)
                    .opacity(ended ? 0.7 : 0.5)

                Spacer()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.status.label)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(primaryText)
                            .invalidatableContent()

                        if ended {
                            Text("Promotion ended")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(primaryText.opacity(0.5))
                        } else {
                            HStack(spacing: 4) {
                                Text("Changes in ~")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(entry.status.isDouble ? .white.opacity(0.6) : .secondary)
                                Text(nextChangeDescription(at: entry.date))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(entry.status.isDouble ? .white.opacity(0.85) : .primary.opacity(0.85))
                                    .invalidatableContent()
                            }
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
    @Environment(\.colorScheme) private var colorScheme
    let entry: UsageEntry

    private var ended: Bool { UsageStatus.hasPromotionEnded }

    private var background: AnyShapeStyle {
        if ended {
            return AnyShapeStyle(colorScheme == .dark
                ? Color(red: 0.10, green: 0.09, blue: 0.08)
                : Color(red: 0.96, green: 0.94, blue: 0.90))
        }
        return entry.status.isDouble
            ? AnyShapeStyle(entry.status.backgroundGradient)
            : AnyShapeStyle(colorScheme == .dark ? Color.black : Color.white)
    }

    private var primaryText: Color {
        ended ? Color(red: 0.15, green: 0.12, blue: 0.10) : (entry.status.isDouble ? .white : .primary)
    }

    var body: some View {
        ZStack {
            Rectangle().fill(background)

            VStack {
                HStack {
                    Text("Claude")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(primaryText.opacity(0.85))
                    Spacer()
                    Button(intent: RefreshUsageIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(primaryText.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.status.label)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(primaryText)
                            .invalidatableContent()

                        if ended {
                            Text("Promotion ended")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(primaryText.opacity(0.5))
                        } else {
                            HStack(spacing: 4) {
                                Text("Changes in ~")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(entry.status.isDouble ? .white.opacity(0.6) : .secondary)
                                Text(nextChangeDescription(at: entry.date))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(entry.status.isDouble ? .white.opacity(0.85) : .primary.opacity(0.85))
                                    .invalidatableContent()
                            }
                        }
                    }

                    Spacer()

                    ClaudeMascot(size: 70, isPeakHours: !entry.status.isDouble && !ended, isPromotionEnded: ended)
                        .opacity(ended ? 0.7 : 0.5)
                }
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

// MARK: - Lock Screen Widgets

struct CircularLockScreenView: View {
    let entry: UsageEntry
    private var ended: Bool { UsageStatus.hasPromotionEnded }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 1) {
                Image(systemName: ended ? "checkmark.circle" : (entry.status.isDouble ? "sparkles" : "clock"))
                    .font(.system(size: 14, weight: .bold))

                Text(ended ? "1x" : (entry.status.isDouble ? "2x" : "1x"))
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct RectangularLockScreenView: View {
    let entry: UsageEntry
    private var ended: Bool { UsageStatus.hasPromotionEnded }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: ended ? "checkmark.circle" : (entry.status.isDouble ? "sparkles" : "clock"))
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text("Claude")
                    .font(.system(size: 12, weight: .semibold))
                    .widgetAccentable()

                if ended {
                    Text("Normal Usage")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("Promotion ended")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                } else {
                    Text(entry.status.isDouble ? "2x Usage Active" : "Peak Hours")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("Changes in ~\(nextChangeDescription(at: entry.date))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct InlineLockScreenView: View {
    let entry: UsageEntry
    private var ended: Bool { UsageStatus.hasPromotionEnded }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: ended ? "checkmark.circle" : "sparkles")
            if ended {
                Text("Claude Normal Usage")
            } else {
                Text(entry.status.isDouble ? "Claude 2x Active" : "Claude Peak Hours")
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}

// MARK: - Lock Screen Widget Definition

struct LockScreenEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: UsageEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        default:
            CircularLockScreenView(entry: entry)
        }
    }
}

struct LockScreenUsageWidget: Widget {
    let kind = "twotimesusageLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UsageTimelineProvider()) { entry in
            LockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("Claude Usage")
        .description("Shows Claude usage status on the lock screen.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
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
        LockScreenUsageWidget()
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

#Preview("Circular - 2x", as: .accessoryCircular) {
    LockScreenUsageWidget()
} timeline: {
    UsageEntry(date: .now, status: .doubleUsage)
}

#Preview("Rectangular - 2x", as: .accessoryRectangular) {
    LockScreenUsageWidget()
} timeline: {
    UsageEntry(date: .now, status: .doubleUsage)
}

#Preview("Inline - 2x", as: .accessoryInline) {
    LockScreenUsageWidget()
} timeline: {
    UsageEntry(date: .now, status: .doubleUsage)
}
