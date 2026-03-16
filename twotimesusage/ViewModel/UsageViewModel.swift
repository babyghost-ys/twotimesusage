import Foundation
import Combine

@Observable
class UsageViewModel {
    private(set) var currentDate = Date()
    private var timerCancellable: AnyCancellable?

    private static let utc = TimeZone(identifier: "UTC") ?? .gmt

    var status: UsageStatus { UsageStatus.current(at: currentDate) }

    var countdown: (hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, nextChangeDate(from: currentDate).timeIntervalSince(currentDate))
        return (Int(interval) / 3600, (Int(interval) % 3600) / 60, Int(interval) % 60)
    }

    var isWeekend: Bool {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = Self.utc
        let wd = cal.component(.weekday, from: currentDate)
        return wd == 1 || wd == 7
    }

    var peakHoursLocal: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "h:mm a"

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = Self.utc
        var s = cal.dateComponents([.year, .month, .day], from: currentDate)
        s.hour = 12; s.minute = 0; s.second = 0
        var e = s
        e.hour = 18

        guard let sd = cal.date(from: s), let ed = cal.date(from: e) else { return "" }
        return "\(formatter.string(from: sd)) – \(formatter.string(from: ed))"
    }

    init() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in self?.currentDate = date }
    }
}
