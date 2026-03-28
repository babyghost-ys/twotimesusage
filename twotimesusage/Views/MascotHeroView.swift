import SwiftUI

struct MascotHeroView: View {
    let status: UsageStatus

    private var mascotExpression: MascotExpression {
        if UsageStatus.hasPromotionEnded { return .content }
        return status.isDouble ? .excited : .sleepy
    }

    private var backdropColours: [Color] {
        if UsageStatus.hasPromotionEnded {
            return [
                anthropicWarmGrey.opacity(0.2),
                anthropicCream.opacity(0.1),
                .clear,
            ]
        }
        if status.isDouble {
            return [
                Color(red: 0.91, green: 0.52, blue: 0.17).opacity(0.2),
                Color(red: 0.36, green: 0.67, blue: 0.29).opacity(0.1),
                Color(red: 0.29, green: 0.56, blue: 0.80).opacity(0.05),
                .clear,
            ]
        }
        return [
            claudeCoral.opacity(0.2),
            claudeCoral.opacity(0.05),
            .clear,
        ]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: backdropColours,
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)

            ClaudeMascot(size: 98, expression: mascotExpression)
        }
    }
}
