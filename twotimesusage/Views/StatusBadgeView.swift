import SwiftUI

struct StatusBadgeView: View {
    let status: UsageStatus

    private var badgeLabel: String {
        if UsageStatus.hasPromotionEnded { return "PROMOTION ENDED" }
        return status.isDouble ? "2x ACTIVE" : "PEAK HOURS"
    }

    private var badgeShadowColour: Color {
        if UsageStatus.hasPromotionEnded { return anthropicDark.opacity(0.15) }
        return status.isDouble
            ? Color(red: 0.91, green: 0.52, blue: 0.17).opacity(0.3)
            : claudeCoral.opacity(0.3)
    }

    var body: some View {
        Text(badgeLabel)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .tracking(2)
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(accentGradient(for: status))
            )
            .shadow(color: badgeShadowColour, radius: 16, y: 4)
    }
}
