import SwiftUI

struct ScheduleCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let currentDate: Date
    let peakHoursLocal: String
    let isWeekend: Bool

    private var backgroundColour: Color {
        colorScheme == .dark
            ? Color(red: 0.06, green: 0.06, blue: 0.07)
            : Color(red: 0.97, green: 0.97, blue: 0.98)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Weekday Schedule")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            timelineBar

            VStack(alignment: .leading, spacing: 14) {
                scheduleRow(
                    colour: claudeCoral,
                    title: "Peak Hours",
                    detail: "Weekdays \(peakHoursLocal)"
                )
                scheduleRow(
                    colour: Color(red: 0.36, green: 0.67, blue: 0.29),
                    title: "2x Usage",
                    detail: "Outside peak + all weekends"
                )
            }

            if isWeekend {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(accentGradient(for: .doubleUsage))
                        .frame(width: 4, height: 28)
                    Text("It's the weekend — 2x usage all day")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.7))
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(CardBackground())
    }

    private var timelineBar: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let offset = Double(TimeZone.current.secondsFromGMT(for: currentDate)) / 3600.0
            let startFrac = ((12.0 + offset).truncatingRemainder(dividingBy: 24) + 24)
                .truncatingRemainder(dividingBy: 24) / 24.0
            let endFrac = ((18.0 + offset).truncatingRemainder(dividingBy: 24) + 24)
                .truncatingRemainder(dividingBy: 24) / 24.0

            let cal = Calendar.current
            let nowFrac = (Double(cal.component(.hour, from: currentDate))
                + Double(cal.component(.minute, from: currentDate)) / 60.0) / 24.0

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.36, green: 0.67, blue: 0.29).opacity(0.7))
                    .frame(height: 14)

                if startFrac < endFrac {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(claudeCoral.opacity(0.85))
                        .frame(width: w * CGFloat(endFrac - startFrac), height: 14)
                        .offset(x: w * CGFloat(startFrac))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(claudeCoral.opacity(0.85))
                        .frame(width: w * CGFloat(1 - startFrac), height: 14)
                        .offset(x: w * CGFloat(startFrac))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(claudeCoral.opacity(0.85))
                        .frame(width: w * CGFloat(endFrac), height: 14)
                }

                Circle()
                    .fill(backgroundColour)
                    .frame(width: 8, height: 8)
                    .shadow(color: backgroundColour.opacity(0.4), radius: 4)
                    .offset(x: w * CGFloat(nowFrac) - 4)
            }

            HStack {
                Text("12am")
                Spacer()
                Text("6am")
                Spacer()
                Text("12pm")
                Spacer()
                Text("6pm")
                Spacer()
                Text("12am")
            }
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundStyle(.primary.opacity(0.25))
            .offset(y: 20)
        }
        .frame(height: 40)
    }

    private func scheduleRow(colour: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(colour)
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
