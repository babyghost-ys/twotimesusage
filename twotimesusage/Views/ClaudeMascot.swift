import SwiftUI

enum MascotExpression {
    case excited    // chevron eyes — 2x active
    case sleepy     // dash eyes — peak hours
    case content    // dot eyes — promotion ended, calm
}

struct ClaudeMascot: View {
    let size: CGFloat
    var expression: MascotExpression = .excited

    // Legacy convenience
    var isPeakHours: Bool {
        get { expression == .sleepy }
        set { expression = newValue ? .sleepy : .excited }
    }

    init(size: CGFloat, isPeakHours: Bool = false) {
        self.size = size
        self.expression = isPeakHours ? .sleepy : .excited
    }

    init(size: CGFloat, expression: MascotExpression) {
        self.size = size
        self.expression = expression
    }

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

            switch expression {
            case .sleepy:
                // Dash eyes: —  —
                let eyeStroke: CGFloat = 0.7 * s
                var leftEye = Path()
                leftEye.move(to: CGPoint(x: 3.0 * s, y: 4.5 * s))
                leftEye.addLine(to: CGPoint(x: 5.0 * s, y: 4.5 * s))
                var rightEye = Path()
                rightEye.move(to: CGPoint(x: 9.0 * s, y: 4.5 * s))
                rightEye.addLine(to: CGPoint(x: 11.0 * s, y: 4.5 * s))
                context.stroke(leftEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
                context.stroke(rightEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))

            case .excited:
                // Chevron eyes: > <
                let eyeStroke: CGFloat = 0.7 * s
                var leftEye = Path()
                leftEye.move(to: CGPoint(x: 3.5 * s, y: 3.8 * s))
                leftEye.addLine(to: CGPoint(x: 4.5 * s, y: 4.5 * s))
                leftEye.addLine(to: CGPoint(x: 3.5 * s, y: 5.2 * s))
                var rightEye = Path()
                rightEye.move(to: CGPoint(x: 10.5 * s, y: 3.8 * s))
                rightEye.addLine(to: CGPoint(x: 9.5 * s, y: 4.5 * s))
                rightEye.addLine(to: CGPoint(x: 10.5 * s, y: 5.2 * s))
                context.stroke(leftEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))
                context.stroke(rightEye, with: .color(eyeColour), style: StrokeStyle(lineWidth: eyeStroke, lineCap: .square, lineJoin: .miter))

            case .content:
                // Dot eyes: round filled circles — calm and happy
                let dotRadius: CGFloat = 0.55 * s
                let leftDot = Path(ellipseIn: CGRect(
                    x: 4.0 * s - dotRadius, y: 4.5 * s - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                ))
                let rightDot = Path(ellipseIn: CGRect(
                    x: 10.0 * s - dotRadius, y: 4.5 * s - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                ))
                context.fill(leftDot, with: .color(eyeColour))
                context.fill(rightDot, with: .color(eyeColour))
            }
        }
        .frame(width: size, height: size / 14 * 11)
    }
}
