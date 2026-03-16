import SwiftUI

// MARK: - Usage Status

enum UsageStatus {
    case doubleUsage
    case normalUsage

    static func current(at date: Date = .now) -> UsageStatus {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let weekday = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        let isWeekend = weekday == 1 || weekday == 7
        if isWeekend { return .doubleUsage }
        return (hour >= 12 && hour < 18) ? .normalUsage : .doubleUsage
    }

    var label: String {
        switch self {
        case .doubleUsage: "2x Usage"
        case .normalUsage: "Peak Hours"
        }
    }

    var isDouble: Bool { self == .doubleUsage }
}

// MARK: - Colours

let ultrathinkColours: [Color] = [
    Color(red: 0.83, green: 0.27, blue: 0.17),
    Color(red: 0.91, green: 0.52, blue: 0.17),
    Color(red: 0.91, green: 0.77, blue: 0.17),
    Color(red: 0.36, green: 0.67, blue: 0.29),
    Color(red: 0.29, green: 0.56, blue: 0.80),
    Color(red: 0.48, green: 0.37, blue: 0.65),
]

let claudeCoral = Color(red: 0.85, green: 0.47, blue: 0.34)

let ultrathinkGradient = LinearGradient(
    colors: ultrathinkColours,
    startPoint: .leading,
    endPoint: .trailing
)

func accentGradient(for status: UsageStatus) -> LinearGradient {
    status.isDouble
        ? LinearGradient(colors: ultrathinkColours, startPoint: .leading, endPoint: .trailing)
        : LinearGradient(colors: [claudeCoral, claudeCoral], startPoint: .leading, endPoint: .trailing)
}

// MARK: - Next Change Date

func nextChangeDate(from date: Date) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let weekday = calendar.component(.weekday, from: date)
    let hour = calendar.component(.hour, from: date)
    let isWeekend = weekday == 1 || weekday == 7

    if isWeekend {
        let daysUntilMonday = weekday == 7 ? 2 : 1
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 12; c.minute = 0; c.second = 0
        let base = calendar.date(from: c)!
        return calendar.date(byAdding: .day, value: daysUntilMonday, to: base)!
    } else if hour >= 12 && hour < 18 {
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 18; c.minute = 0; c.second = 0
        return calendar.date(from: c)!
    } else if hour < 12 {
        var c = calendar.dateComponents([.year, .month, .day], from: date)
        c.hour = 12; c.minute = 0; c.second = 0
        return calendar.date(from: c)!
    } else {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
        let tw = calendar.component(.weekday, from: tomorrow)
        if tw == 1 || tw == 7 {
            let d = tw == 7 ? 3 : 2
            var c = calendar.dateComponents([.year, .month, .day], from: date)
            c.hour = 12; c.minute = 0; c.second = 0
            let base = calendar.date(from: c)!
            return calendar.date(byAdding: .day, value: d, to: base)!
        } else {
            var c = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            c.hour = 12; c.minute = 0; c.second = 0
            return calendar.date(from: c)!
        }
    }
}

// MARK: - Claude Mascot

struct ClaudeMascot: View {
    let pixelSize: CGFloat

    private let bodyColour = Color(red: 0.80, green: 0.55, blue: 0.40)
    private let eyeColour = Color(red: 0.15, green: 0.12, blue: 0.10)

    // 14 columns x 11 rows
    // 0 = empty, 1 = body, 2 = eye
    // >< chevron eyes, moved closer to edges
    private let grid: [[Int]] = [
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0],  // head
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0],  // head
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0],  // head
        [1,1,2,2,1,1,1,1,1,1,2,2,1,1],  // ears + eye top
        [1,1,1,1,2,2,1,1,2,2,1,1,1,1],  // ears + eye point
        [0,1,2,2,1,1,1,1,1,1,2,2,1,0],  // body + eye bottom
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0],  // body
        [0,1,1,1,1,1,1,1,1,1,1,1,1,0],  // body
        [0,1,1,0,1,1,0,0,1,1,0,1,1,0],  // 4 legs
        [0,1,1,0,1,1,0,0,1,1,0,1,1,0],  // 4 legs
        [0,1,1,0,1,1,0,0,1,1,0,1,1,0],  // 4 legs
    ]

    var body: some View {
        Canvas { context, _ in
            let p = pixelSize
            for (row, cols) in grid.enumerated() {
                for (col, val) in cols.enumerated() {
                    guard val != 0 else { continue }
                    let colour = val == 2 ? eyeColour : bodyColour
                    let rect = CGRect(x: CGFloat(col) * p, y: CGFloat(row) * p, width: p, height: p)
                    context.fill(Path(rect), with: .color(colour))
                }
            }
        }
        .frame(width: pixelSize * 14, height: pixelSize * 11)
    }
}
