import SwiftUI
import Pow

/// SwiftUI implementation of HoldButton with POW animations
struct HoldButtonView: View {
  @State private var arcProgress: CGFloat = 0
  @State private var blurRadius: CGFloat = 20
  @State private var currentPhase = ""
  @State private var phaseOpacity: CGFloat = 0
  @State private var isCompleted = false
  @State private var isAnimating = false
  @State private var animationTask: Task<Void, Never>?

  var disabled = false
  var onArcComplete: (() -> Void)

  init(onArcComplete: @escaping () -> Void = {}) {
    self.onArcComplete = onArcComplete
  }

  private let BUTTON_SIZE: CGFloat = 80
  private let ARC_RADIUS: CGFloat = 45
  private let ANIMATION_DURATION: TimeInterval = 3.0

  var body: some View {
    ZStack {
      // Growing morphing circle (POW iris-like effect)
      if arcProgress > 0 {
        Circle()
          .fill(Color.amber.opacity(0.1))
          .frame(width: BUTTON_SIZE + (arcProgress * 300), height: BUTTON_SIZE + (arcProgress * 300))
          .shadow(color: Color.amber.opacity(0.6 * arcProgress), radius: 30 * arcProgress, x: 0, y: 0)
          .blur(radius: 10 * arcProgress)
          .transition(.movingParts.iris(blurRadius: 20))
      }

      // Background button with dynamic size
      Circle()
        .fill(Color.void)
        .frame(width: BUTTON_SIZE, height: BUTTON_SIZE)
        .overlay(
          Circle()
            .stroke(Color.amber, lineWidth: 1)
            .opacity(isCompleted ? 0.4 : (0.7 + 0.2 * arcProgress))
        )

      // Blur effect (no clipping - allow glow overflow)
      BlurView(style: .dark)
        .frame(width: BUTTON_SIZE, height: BUTTON_SIZE)
        .clipShape(Circle())
        .opacity(blurRadius / 20.0)
        .shadow(color: Color.amber.opacity(0.4 * arcProgress), radius: 15 * arcProgress, x: 0, y: 0)

      // Arc canvas
      ArcCanvasView(
        arcProgress: arcProgress,
        radius: ARC_RADIUS
      )
      .frame(width: BUTTON_SIZE + 20, height: BUTTON_SIZE + 20)
      .shadow(color: Color.amber.opacity(0.5 * arcProgress), radius: 8 * arcProgress, x: 0, y: 0)

      // Center dot with glow
      Circle()
        .fill(Color.amber)
        .frame(width: 8, height: 8)
        .shadow(color: Color.amber.opacity(0.8 * arcProgress), radius: 6 * arcProgress, x: 0, y: 0)

      // Phase label
      if !currentPhase.isEmpty {
        VStack(spacing: 12) {
          Text(currentPhase)
            .font(.custom("Georgia", size: 14))
            .foregroundColor(Color.amber)
            .opacity(phaseOpacity)

          Spacer()
        }
        .frame(height: BUTTON_SIZE)
        .offset(y: -BUTTON_SIZE / 2 - 12)
      }
    }
    .frame(width: BUTTON_SIZE, height: BUTTON_SIZE)
    .gesture(
      LongPressGesture(minimumDuration: 0.05)
        .onChanged { isPressing in
          if isPressing && !disabled && !isCompleted && !isAnimating {
            beginAnimation()
          }
        }
        .onEnded { _ in
          if isAnimating && !isCompleted {
            resetAnimation()
          }
        }
    )
    .transition(
      isCompleted ? .movingParts.pop(Color.amber) : .identity
    )
    .scaleEffect(isCompleted ? 0.95 : 1.0)
  }

  private func beginAnimation() {
    isAnimating = true
    print("🔴 Animation started")

    // Cancel any existing animation
    animationTask?.cancel()

    animationTask = Task {
      let startTime = Date()
      let frameInterval = 1.0 / 60.0  // 60 FPS

      while !Task.isCancelled {
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = min(elapsed / ANIMATION_DURATION, 1.0)

        print("📊 Progress: \(String(format: "%.2f", progress))")

        // Update state on main thread
        DispatchQueue.main.async {
          self.arcProgress = progress
          self.blurRadius = 20 - (progress * 20)
          self.updatePhaseLabels(for: progress)
        }

        if progress >= 1.0 {
          completeAnimation()
          break
        }

        // Wait for next frame
        try? await Task.sleep(nanoseconds: UInt64(frameInterval * 1_000_000_000))
      }
    }
  }

  private func completeAnimation() {
    print("✅ Animation completed")
    isAnimating = false
    isCompleted = true

    // Trigger haptic
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

    // Fade out phase label
    withAnimation(.easeOut(duration: 0.2)) {
      phaseOpacity = 0
    }

    // Trigger callback
    onArcComplete()
  }

  private func resetAnimation() {
    print("⏮️ Animation reset")
    animationTask?.cancel()
    animationTask = nil
    isAnimating = false
    currentPhase = ""

    withAnimation(.easeOut(duration: 0.3)) {
      arcProgress = 0
      blurRadius = 20
      phaseOpacity = 0
      isCompleted = false
    }
  }

  private func updatePhaseLabels(for progress: CGFloat) {
    let phases: [(threshold: CGFloat, label: String)] = [
      (0.0, "Noticing"),
      (0.333, "Reading"),
      (0.667, "Recognising"),
      (1.0, ""),
    ]

    var newPhase = ""
    var targetAlpha: CGFloat = 0

    for i in 0..<phases.count {
      let (threshold, label) = phases[i]

      if progress >= threshold {
        newPhase = label

        if i < phases.count - 1 {
          let nextThreshold = phases[i + 1].threshold
          let transitionStart = nextThreshold - 0.04

          if progress >= transitionStart {
            let transitionProgress = (progress - transitionStart) / 0.04
            targetAlpha = max(0, 1 - transitionProgress)
          } else {
            targetAlpha = 1.0
          }
        } else {
          targetAlpha = 0
        }
      }
    }

    // Update phase if changed
    if newPhase != currentPhase {
      currentPhase = newPhase
      targetAlpha = newPhase.isEmpty ? 0 : 1.0

      // Trigger haptic at phase transitions
      if !newPhase.isEmpty {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
      }
    }

    phaseOpacity = targetAlpha
  }
}

/// SwiftUI wrapper for Core Graphics arc drawing
struct ArcCanvasView: View {
  let arcProgress: CGFloat
  let radius: CGFloat

  var body: some View {
    Canvas { context, size in
      let centerX = size.width / 2
      let centerY = size.height / 2

      // Draw static circle
      drawStaticCircle(context, centerX: centerX, centerY: centerY)

      // Draw animated arc
      drawAnimatedArc(context, centerX: centerX, centerY: centerY)
    }
  }

  private func drawStaticCircle(_ context: GraphicsContext, centerX: CGFloat, centerY: CGFloat) {
    var path = Path()
    path.addArc(
      center: CGPoint(x: centerX, y: centerY),
      radius: radius,
      startAngle: .degrees(0),
      endAngle: .degrees(360),
      clockwise: false
    )

    var stroke = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
    context.stroke(
      path,
      with: .color(Color.amber.opacity(0.3)),
      style: stroke
    )
  }

  private func drawAnimatedArc(_ context: GraphicsContext, centerX: CGFloat, centerY: CGFloat) {
    guard arcProgress > 0 else { return }

    let angle = arcProgress * 360
    let startAngle = Angle.degrees(-90)
    let endAngle = Angle.degrees(angle - 90)

    let colors = rainbowColors()
    let segmentCount = Int(max(1, arcProgress * 40))

    // Draw glow layers
    let glowLayers = 8
    for layer in 0..<glowLayers {
      let layerProgress = CGFloat(layer) / CGFloat(glowLayers)
      let layerOpacity = (1.0 - layerProgress) * 0.15

      for i in 0..<segmentCount {
        let segmentStart = CGFloat(i) / CGFloat(segmentCount)
        let segmentEnd = CGFloat(i + 1) / CGFloat(segmentCount)

        let angle1 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * segmentStart
        let angle2 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * segmentEnd

        let colorIndex = Int(segmentStart * CGFloat(colors.count - 1))
        let color = colors[min(colorIndex, colors.count - 1)]

        var path = Path()
        path.addArc(
          center: CGPoint(x: centerX, y: centerY),
          radius: radius + CGFloat(layer) * 1.2,
          startAngle: .degrees(angle1),
          endAngle: .degrees(angle2),
          clockwise: false
        )

        var stroke = StrokeStyle(
          lineWidth: 4 + CGFloat(layer) * 0.5,
          lineCap: .round,
          lineJoin: .round
        )
        context.stroke(
          path,
          with: .color(color.opacity(layerOpacity)),
          style: stroke
        )
      }
    }

    // Draw main arc
    for i in 0..<segmentCount {
      let segmentStart = CGFloat(i) / CGFloat(segmentCount)
      let segmentEnd = CGFloat(i + 1) / CGFloat(segmentCount)

      let angle1 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * segmentStart
      let angle2 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * segmentEnd

      let colorIndex = Int(segmentStart * CGFloat(colors.count - 1))
      let color = colors[min(colorIndex, colors.count - 1)]

      var path = Path()
      path.addArc(
        center: CGPoint(x: centerX, y: centerY),
        radius: radius,
        startAngle: .degrees(angle1),
        endAngle: .degrees(angle2),
        clockwise: false
      )

      var stroke = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
      context.stroke(path, with: .color(color), style: stroke)
    }
  }

  private func rainbowColors() -> [Color] {
    return [
      Color(red: 1.0, green: 0.3, blue: 0.4),    // Rose
      Color(red: 1.0, green: 0.5, blue: 0.2),    // Orange
      Color(red: 1.0, green: 0.75, blue: 0.1),   // Gold
      Color(red: 0.5, green: 0.85, blue: 0.3),   // Green
      Color(red: 0.2, green: 0.7, blue: 0.95),   // Sky
      Color(red: 0.6, green: 0.4, blue: 0.95),   // Purple
      Color(red: 0.9, green: 0.3, blue: 0.7),    // Magenta
      Color(red: 1.0, green: 0.3, blue: 0.5),    // Pink
    ]
  }
}

/// SwiftUI wrapper for UIVisualEffectView
struct BlurView: UIViewRepresentable {
  let style: UIBlurEffect.Style

  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: style))
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
