import SwiftUI

struct CountdownView: View {
    let status: UsageStatus
    let countdown: (hours: Int, minutes: Int, seconds: Int)

    var body: some View {
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
                .foregroundStyle(.secondary)
        }
    }

    private func digitBlock(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 40, weight: .semibold, design: .monospaced))
            .foregroundStyle(.primary.opacity(0.9))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: text)
    }

    private var colonSeparator: some View {
        Text(":")
            .font(.system(size: 34, weight: .light, design: .monospaced))
            .foregroundStyle(.primary.opacity(0.2))
            .padding(.horizontal, 2)
    }
}
