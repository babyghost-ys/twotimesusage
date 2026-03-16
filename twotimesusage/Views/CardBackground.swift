import SwiftUI

struct CardBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    private var surfaceColour: Color {
        colorScheme == .dark
            ? Color(red: 0.11, green: 0.11, blue: 0.14)
            : Color(red: 0.94, green: 0.94, blue: 0.96)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(surfaceColour)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
            )
    }
}
