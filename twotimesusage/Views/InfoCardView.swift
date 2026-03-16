import SwiftUI

struct InfoCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Promotion")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("Claude is doubling usage outside peak hours for two weeks as a thank you to the community. This is automatic — nothing to enable.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
        .padding(20)
        .background(CardBackground())
    }
}
