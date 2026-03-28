import SwiftUI

struct InfoCardView: View {
    private var title: String {
        UsageStatus.hasPromotionEnded ? "About the Promotion" : "About This Promotion"
    }

    private var description: String {
        if UsageStatus.hasPromotionEnded {
            return "Claude doubled usage outside peak hours for two weeks as a thank you to the community. The promotion ran from 14 March to 28 March 2026."
        }
        return "Claude is doubling usage outside peak hours for two weeks as a thank you to the community. This is automatic — nothing to enable."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
        .padding(20)
        .background(CardBackground())
    }
}
