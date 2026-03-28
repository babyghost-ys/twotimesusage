import Foundation

func nextChangeDate(from date: Date) -> Date {
    let promotionEnd = UsageStatus.promotionEnd

    // After promotion ends, there is no next status change
    if date >= promotionEnd { return date }

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    let weekday = calendar.component(.weekday, from: date)
    let hour = calendar.component(.hour, from: date)
    let isWeekend = weekday == 1 || weekday == 7

    let candidate: Date

    if isWeekend {
        let daysUntilMonday = weekday == 7 ? 2 : 1
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 12; c.minute = 0; c.second = 0
        guard let base = calendar.date(from: c),
              let result = calendar.date(byAdding: .day, value: daysUntilMonday, to: base) else {
            return date
        }
        candidate = result
    } else if hour >= 12 && hour < 18 {
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 18; c.minute = 0; c.second = 0
        candidate = calendar.date(from: c) ?? date
    } else if hour < 12 {
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 12; c.minute = 0; c.second = 0
        candidate = calendar.date(from: c) ?? date
    } else {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else {
            return date
        }
        let tw = calendar.component(.weekday, from: tomorrow)
        if tw == 1 || tw == 7 {
            let d = tw == 7 ? 3 : 2
            var c = calendar.dateComponents([.year, .month, .day], from: date)
            c.hour = 12; c.minute = 0; c.second = 0
            guard let base = calendar.date(from: c),
                  let result = calendar.date(byAdding: .day, value: d, to: base) else {
                return date
            }
            candidate = result
        } else {
            var c = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            c.hour = 12; c.minute = 0; c.second = 0
            candidate = calendar.date(from: c) ?? date
        }
    }

    // Cap at promotion end — don't count down past when the promotion finishes
    return min(candidate, promotionEnd)
}
