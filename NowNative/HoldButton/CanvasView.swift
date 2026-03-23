import UIKit

/// Draws the static circle outline and animated arc path using Core Graphics.
class CanvasView: UIView {
  // MARK: - Configuration

  let ARC_RADIUS: CGFloat = 45
  let ARC_CENTER_X: CGFloat = 50  // SVG center offset (100pt canvas, centered)
  let ARC_CENTER_Y: CGFloat = 50

  // MARK: - State

  var arcProgress: CGFloat = 0 {
    didSet { setNeedsDisplay() }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    backgroundColor = .clear
    isOpaque = false
  }

  // MARK: - Drawing

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    drawStaticCircle(context)
    drawAnimatedArc(context)
  }

  /// Draw the baseline circle (faded amber outline, 2pt stroke, 30% opacity)
  private func drawStaticCircle(_ context: CGContext) {
    let path = UIBezierPath(
      arcCenter: CGPoint(x: ARC_CENTER_X, y: ARC_CENTER_Y),
      radius: ARC_RADIUS,
      startAngle: 0,
      endAngle: CGFloat.pi * 2,
      clockwise: true
    )

    Colors.amber.withAlphaComponent(0.3).setStroke()
    path.lineWidth = 2
    path.stroke()
  }

  /// Draw the animated arc with blurred rainbow gradient (Apple Intelligence style)
  private func drawAnimatedArc(_ context: CGContext) {
    guard arcProgress > 0 else { return }

    let angle = arcProgress * 360
    let radians = (angle - 90) * (CGFloat.pi / 180)
    let startAngle = CGFloat(-90) * (CGFloat.pi / 180)
    let endAngle = radians

    // Draw blurred glow layers for smooth gradient effect
    let glowLayers = 8
    let colors = rainbowColors()
    let segmentCount = Int(max(1, arcProgress * 40))

    // First pass: Draw thick blurred base (glow)
    for layer in 0..<glowLayers {
      let layerProgress = CGFloat(layer) / CGFloat(glowLayers)
      let layerOpacity = (1.0 - layerProgress) * 0.15  // Fade out for glow effect

      for i in 0..<segmentCount {
        let segmentStart = startAngle + (CGFloat(i) / CGFloat(segmentCount)) * (endAngle - startAngle)
        let segmentEnd = startAngle + (CGFloat(i + 1) / CGFloat(segmentCount)) * (endAngle - startAngle)

        let colorIndex = Int(CGFloat(i) / CGFloat(segmentCount) * CGFloat(colors.count - 1))
        let baseColor = colors[min(colorIndex, colors.count - 1)]
        let glowColor = baseColor.withAlphaComponent(layerOpacity)

        let path = UIBezierPath(
          arcCenter: CGPoint(x: ARC_CENTER_X, y: ARC_CENTER_Y),
          radius: ARC_RADIUS + CGFloat(layer) * 1.2,
          startAngle: segmentStart,
          endAngle: segmentEnd,
          clockwise: true
        )

        glowColor.setStroke()
        path.lineWidth = 4 + CGFloat(layer) * 0.5
        path.lineCapStyle = .round
        path.stroke()
      }
    }

    // Second pass: Draw sharp main arc on top
    for i in 0..<segmentCount {
      let segmentStart = startAngle + (CGFloat(i) / CGFloat(segmentCount)) * (endAngle - startAngle)
      let segmentEnd = startAngle + (CGFloat(i + 1) / CGFloat(segmentCount)) * (endAngle - startAngle)

      let colorIndex = Int(CGFloat(i) / CGFloat(segmentCount) * CGFloat(colors.count - 1))
      let color = colors[min(colorIndex, colors.count - 1)]

      let path = UIBezierPath(
        arcCenter: CGPoint(x: ARC_CENTER_X, y: ARC_CENTER_Y),
        radius: ARC_RADIUS,
        startAngle: segmentStart,
        endAngle: segmentEnd,
        clockwise: true
      )

      color.setStroke()
      path.lineWidth = 3
      path.lineCapStyle = .round
      path.stroke()
    }
  }

  /// Generate soft rainbow colors for the flowing arc
  private func rainbowColors() -> [UIColor] {
    return [
      UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 0.85),    // Rose
      UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.85),    // Orange
      UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 0.85),   // Gold
      UIColor(red: 0.5, green: 0.85, blue: 0.3, alpha: 0.85),   // Green
      UIColor(red: 0.2, green: 0.7, blue: 0.95, alpha: 0.85),   // Sky
      UIColor(red: 0.6, green: 0.4, blue: 0.95, alpha: 0.85),   // Purple
      UIColor(red: 0.9, green: 0.3, blue: 0.7, alpha: 0.85),    // Magenta
      UIColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 0.85),    // Pink
    ]
  }
}
