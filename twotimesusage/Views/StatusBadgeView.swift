import SwiftUI

struct StatusBadgeView: View {
    let status: UsageStatus

    var body: some View {
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
}
