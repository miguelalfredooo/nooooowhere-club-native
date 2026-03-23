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

  /// Draw the animated arc (amber, 3pt stroke, clockwise from top)
  private func drawAnimatedArc(_ context: CGContext) {
    let angle = arcProgress * 360  // 0 to 360 degrees
    let radians = (angle - 90) * (CGFloat.pi / 180)  // Start from top (offset -90°)

    let startAngle = CGFloat(-90) * (CGFloat.pi / 180)  // Start at top
    let endAngle = radians

    let path = UIBezierPath(
      arcCenter: CGPoint(x: ARC_CENTER_X, y: ARC_CENTER_Y),
      radius: ARC_RADIUS,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true
    )

    Colors.amber.setStroke()
    path.lineWidth = 3
    path.lineCapStyle = .round
    path.stroke()
  }
}
