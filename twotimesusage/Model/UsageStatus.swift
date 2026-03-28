import Foundation

enum UsageStatus {
    case doubleUsage
    case normalUsage

    private static let utc = TimeZone(identifier: "UTC") ?? .gmt

    /// Promotion runs until end of 2026-03-28 UTC (last day inclusive).
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
        return (hour >= 12 && hour < 18) ? .normalUsage : .doubleUsage
    }

    var label: String {
        switch self {
        case .doubleUsage: "2x Usage"
        case .normalUsage: Self.hasPromotionEnded ? "Normal" : "Peak Hours"
        }
    }

    var isDouble: Bool { self == .doubleUsage }
}
