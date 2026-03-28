import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = UsageViewModel()

    private var promotionEnded: Bool { UsageStatus.hasPromotionEnded }

    private var backgroundColour: Color {
        if promotionEnded {
            return colorScheme == .dark
                ? Color(red: 0.10, green: 0.09, blue: 0.08)
                : anthropicCream
        }
        return colorScheme == .dark
            ? Color(red: 0.06, green: 0.06, blue: 0.07)
            : Color(red: 0.97, green: 0.97, blue: 0.98)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                StatusBadgeView(status: viewModel.status)
                    .padding(.top, 24)
                    .padding(.bottom, 44)

                MascotHeroView(status: viewModel.status)
                    .padding(.bottom, 28)

                Text(viewModel.status.label)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(accentGradient(for: viewModel.status))
                    .padding(.bottom, 6)

                if promotionEnded {
                    Text("The 2x promotion has ended.\nThanks for the ride.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 48)
                } else {
                    CountdownView(status: viewModel.status, countdown: viewModel.countdown)
                        .padding(.bottom, 48)

                    ScheduleCardView(
                        currentDate: viewModel.currentDate,
                        peakHoursLocal: viewModel.peakHoursLocal,
                        isWeekend: viewModel.isWeekend
                    )
                    .padding(.bottom, 16)
                }

                InfoCardView()
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
        .background(backgroundColour.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
