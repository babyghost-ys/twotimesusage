import SwiftUI

struct MascotHeroView: View {
    let status: UsageStatus

    var body: some View {
        ZStack {
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

            ClaudeMascot(size: 98, isPeakHours: !status.isDouble)
        }
    }
}
