import SwiftUI

let ultrathinkColours: [Color] = [
    Color(red: 0.83, green: 0.27, blue: 0.17),
    Color(red: 0.91, green: 0.52, blue: 0.17),
    Color(red: 0.91, green: 0.77, blue: 0.17),
    Color(red: 0.36, green: 0.67, blue: 0.29),
    Color(red: 0.29, green: 0.56, blue: 0.80),
    Color(red: 0.48, green: 0.37, blue: 0.65),
]

let claudeCoral = Color(red: 0.85, green: 0.47, blue: 0.34)

let ultrathinkGradient = LinearGradient(
    colors: ultrathinkColours,
    startPoint: .leading,
    endPoint: .trailing
)

func accentGradient(for status: UsageStatus) -> LinearGradient {
    status.isDouble
        ? LinearGradient(colors: ultrathinkColours, startPoint: .leading, endPoint: .trailing)
        : LinearGradient(colors: [claudeCoral, claudeCoral], startPoint: .leading, endPoint: .trailing)
}
