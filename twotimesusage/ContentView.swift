import SwiftUI
import Combine

// MARK: - Background

private let surfaceColour = Color(red: 0.11, green: 0.11, blue: 0.14)
private let backgroundColour = Color(red: 0.06, green: 0.06, blue: 0.07)

struct ContentView: View {
    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var status: UsageStatus {
        UsageStatus.current(at: currentDate)
    }

    private var countdown: (hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, nextChangeDate(from: currentDate).timeIntervalSince(currentDate))
        return (Int(interval) / 3600, (Int(interval) % 3600) / 60, Int(interval) % 60)
    }

    private var isWeekend: Bool {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let wd = cal.component(.weekday, from: currentDate)
        return wd == 1 || wd == 7
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                statusBadge
                    .padding(.top, 24)
                    .padding(.bottom, 44)

                mascotHero
                    .padding(.bottom, 28)

                statusLabel
                    .padding(.bottom, 6)

                countdownView
                    .padding(.bottom, 48)

                scheduleCard
                    .padding(.bottom, 16)

                infoCard
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
        .background(backgroundColour.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onReceive(timer) { date in
            currentDate = date
        }
    }

    // MARK: - Status Badge

    private var statusBadge: some View {
        Text(status.isDouble ? "2x ACTIVE" : "PEAK HOURS")
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .tracking(2)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(accentGradient(for: status))
            )
            .shadow(
                color: status.isDouble
                    ? Color(red: 0.91, green: 0.52, blue: 0.17).opacity(0.3)
                    : claudeCoral.opacity(0.3),
                radius: 16, y: 4
            )
    }

    // MARK: - Mascot Hero

    private var mascotHero: some View {
        ZStack {
            // Glow halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: status.isDouble
                            ? [
                                Color(red: 0.91, green: 0.52, blue: 0.17).opacity(0.2),
                                Color(red: 0.36, green: 0.67, blue: 0.29).opacity(0.1),
                                Color(red: 0.29, green: 0.56, blue: 0.80).opacity(0.05),
                                .clear,
                              ]
                            : [
                                claudeCoral.opacity(0.2),
                                claudeCoral.opacity(0.05),
                                .clear,
                              ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)

            ClaudeMascot(pixelSize: 7)
        }
    }

    // MARK: - Status Label

    private var statusLabel: some View {
        Text(status.label)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(accentGradient(for: status))
    }

    // MARK: - Countdown

    private var countdownView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 2) {
                digitBlock(String(format: "%02d", countdown.hours))
                colonSeparator
                digitBlock(String(format: "%02d", countdown.minutes))
                colonSeparator
                digitBlock(String(format: "%02d", countdown.seconds))
            }

            Text(status.isDouble ? "until peak hours" : "until 2x resumes")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
        }
    }

    private func digitBlock(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 40, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white.opacity(0.9))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: text)
    }

    private var colonSeparator: some View {
        Text(":")
            .font(.system(size: 34, weight: .light, design: .monospaced))
            .foregroundStyle(.white.opacity(0.2))
            .padding(.horizontal, 2)
    }

    // MARK: - Schedule Card

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Weekday Schedule")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

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
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(cardBackground)
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
                // Full bar — 2x rainbow
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: ultrathinkColours.map { $0.opacity(0.4) },
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 14)

                // Peak overlay
                if startFrac < endFrac {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(claudeCoral.opacity(0.85))
                        .frame(width: w * CGFloat(endFrac - startFrac), height: 14)
                        .offset(x: w * CGFloat(startFrac))
                } else {
                    // Wraps around midnight
                    RoundedRectangle(cornerRadius: 4)
                        .fill(claudeCoral.opacity(0.85))
                        .frame(width: w * CGFloat(1 - startFrac), height: 14)
                        .offset(x: w * CGFloat(startFrac))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(claudeCoral.opacity(0.85))
                        .frame(width: w * CGFloat(endFrac), height: 14)
                }

                // Now indicator
                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .shadow(color: .white.opacity(0.4), radius: 4)
                    .offset(x: w * CGFloat(nowFrac) - 4)
            }

            // Hour labels
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
            .foregroundStyle(.white.opacity(0.25))
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
                    .foregroundStyle(.white.opacity(0.9))
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    private var peakHoursLocal: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "h:mm a"

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var s = cal.dateComponents([.year, .month, .day], from: currentDate)
        s.hour = 12; s.minute = 0; s.second = 0
        var e = s
        e.hour = 18

        guard let sd = cal.date(from: s), let ed = cal.date(from: e) else { return "" }
        return "\(formatter.string(from: sd)) – \(formatter.string(from: ed))"
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Promotion")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Claude is doubling usage outside peak hours for two weeks as a thank you to the community. This is automatic — nothing to enable.")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
                .lineSpacing(5)
        }
        .padding(20)
        .background(cardBackground)
    }

    // MARK: - Shared

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(surfaceColour)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.06), lineWidth: 1)
            )
    }
}

#Preview {
    ContentView()
}
