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

  /// Draw the animated arc with rainbow gradient flow
  private func drawAnimatedArc(_ context: CGContext) {
    let angle = arcProgress * 360  // 0 to 360 degrees
    let radians = (angle - 90) * (CGFloat.pi / 180)  // Start from top (offset -90°)

    let startAngle = CGFloat(-90) * (CGFloat.pi / 180)  // Start at top
    let endAngle = radians

    // Draw gradient arc in segments for smooth rainbow effect
    let segmentCount = Int(max(1, arcProgress * 60))  // More segments as arc fills
    let colors = rainbowColors()

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
      UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 0.9),    // Soft red
      UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.9),    // Soft orange
      UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.9),    // Soft yellow
      UIColor(red: 0.4, green: 0.9, blue: 0.3, alpha: 0.9),    // Soft green
      UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 0.9),    // Soft cyan
      UIColor(red: 0.5, green: 0.4, blue: 0.9, alpha: 0.9),    // Soft blue
      UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 0.9),    // Soft violet
      UIColor(red: 1.0, green: 0.3, blue: 0.6, alpha: 0.9),    // Soft magenta
    ]
  }
}
