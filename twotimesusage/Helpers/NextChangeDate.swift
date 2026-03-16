import Foundation

func nextChangeDate(from date: Date) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    let weekday = calendar.component(.weekday, from: date)
    let hour = calendar.component(.hour, from: date)
    let isWeekend = weekday == 1 || weekday == 7

    if isWeekend {
        let daysUntilMonday = weekday == 7 ? 2 : 1
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 12; c.minute = 0; c.second = 0
        guard let base = calendar.date(from: c),
              let result = calendar.date(byAdding: .day, value: daysUntilMonday, to: base) else {
            return date
        }
        return result
    } else if hour >= 12 && hour < 18 {
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 18; c.minute = 0; c.second = 0
        return calendar.date(from: c) ?? date
    } else if hour < 12 {
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 12; c.minute = 0; c.second = 0
        return calendar.date(from: c) ?? date
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
            return result
        } else {
            var c = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            c.hour = 12; c.minute = 0; c.second = 0
            return calendar.date(from: c) ?? date
        }
    }
}
