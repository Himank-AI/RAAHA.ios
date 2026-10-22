import SwiftUI

/// Soft organic corner blob used on the mint "result" screens.
struct CornerWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.62, y: 0))
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.62),
            control1: CGPoint(x: rect.width * 0.55, y: rect.height * 0.30),
            control2: CGPoint(x: rect.width * 0.18, y: rect.height * 0.50)
        )
        path.closeSubpath()
        return path
    }
}

/// Honeydew page with frosted waves in the top-leading and bottom-trailing corners.
struct MintWaveBackground: View {
    var body: some View {
        ZStack {
            Color.honeydew
            CornerWave()
                .fill(Color.frostedBlue.opacity(0.28))
                .frame(width: 300, height: 340)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            CornerWave()
                .rotation(.degrees(180))
                .fill(Color.frostedBlue.opacity(0.28))
                .frame(width: 320, height: 360)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .ignoresSafeArea()
    }
}
