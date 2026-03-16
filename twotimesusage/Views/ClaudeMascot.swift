import SwiftUI

struct ClaudeMascot: View {
    let size: CGFloat
    var isPeakHours: Bool = false

    private let bodyColour = Color(red: 0.80, green: 0.55, blue: 0.40)
    private let eyeColour = Color(red: 0.15, green: 0.12, blue: 0.10)

    private var scaleFactor: CGFloat { size / 14 }

    var body: some View {
        Canvas { context, _ in
            let s = scaleFactor

            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: 1 * s, y: 0))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 0))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 3 * s))
            bodyPath.addLine(to: CGPoint(x: 14 * s, y: 3 * s))
            bodyPath.addLine(to: CGPoint(x: 14 * s, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 13 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 11 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 11 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 10 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 10 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 8 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 8 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 6 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 6 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 4 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 4 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 3 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 3 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 11 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 8 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 0, y: 5 * s))
            bodyPath.addLine(to: CGPoint(x: 0, y: 3 * s))
            bodyPath.addLine(to: CGPoint(x: 1 * s, y: 3 * s))
            bodyPath.closeSubpath()

            context.fill(bodyPath, with: .color(bodyColour))

            let eyeStroke: CGFloat = 0.7 * s
            var leftEye = Path()
            var rightEye = Path()

            if isPeakHours {
                leftEye.move(to: CGPoint(x: 3.0 * s, y: 4.5 * s))
                leftEye.addLine(to: CGPoint(x: 5.0 * s, y: 4.5 * s))
                rightEye.move(to: CGPoint(x: 9.0 * s, y: 4.5 * s))
                rightEye.addLine(to: CGPoint(x: 11.0 * s, y: 4.5 * s))
            } else {
                leftEye.move(to: CGPoint(x: 3.5 * s, y: 3.8 * s))
                leftEye.addLine(to: CGPoint(x: 4.5 * s, y: 4.5 * s))
                leftEye.addLine(to: CGPoint(x: 3.5 * s, y: 5.2 * s))
                rightEye.move(to: CGPoint(x: 10.5 * s, y: 3.8 * s))
                rightEye.addLine(to: CGPoint(x: 9.5 * s, y: 4.5 * s))
                rightEye.addLine(to: CGPoint(x: 10.5 * s, y: 5.2 * s))
            }

            context.stroke(leftEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
            context.stroke(rightEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
        }
        .frame(width: size, height: size / 14 * 11)
    }
}
