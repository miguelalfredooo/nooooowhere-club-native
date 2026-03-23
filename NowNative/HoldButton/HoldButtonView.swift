import SwiftUI
import Pow

struct HoldButtonView: View {
  @State private var progress: CGFloat = 0
  @State private var isCompleted = false
  @State private var currentPhase = ""
  @State private var isHolding = false

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
      // Viewport edge glow (inner glow from edges)
      if progress > 0 {
        VStack(spacing: 0) {
          // Top glow
          LinearGradient(gradient: Gradient(colors: [Color.amber.opacity(0.3 * progress), Color.amber.opacity(0.05 * progress), Color.clear]), startPoint: .top, endPoint: .bottom)
            .frame(height: 150 * progress)

          Spacer()

          // Bottom glow
          LinearGradient(gradient: Gradient(colors: [Color.clear, Color.amber.opacity(0.05 * progress), Color.amber.opacity(0.3 * progress)]), startPoint: .top, endPoint: .bottom)
            .frame(height: 150 * progress)
        }
        .ignoresSafeArea()

        HStack(spacing: 0) {
          // Left glow
          LinearGradient(gradient: Gradient(colors: [Color.amber.opacity(0.3 * progress), Color.amber.opacity(0.05 * progress), Color.clear]), startPoint: .leading, endPoint: .trailing)
            .frame(width: 150 * progress)

          Spacer()

          // Right glow
          LinearGradient(gradient: Gradient(colors: [Color.clear, Color.amber.opacity(0.05 * progress), Color.amber.opacity(0.3 * progress)]), startPoint: .leading, endPoint: .trailing)
            .frame(width: 150 * progress)
        }
        .ignoresSafeArea()
      }

      // Main button circle
      Circle()
        .fill(Color.void)
        .frame(width: BUTTON_SIZE, height: BUTTON_SIZE)
        .overlay(Circle().stroke(Color.amber, lineWidth: 1).opacity(0.7 + 0.2 * progress))

      // Dark blur
      BlurView(style: .dark)
        .frame(width: BUTTON_SIZE, height: BUTTON_SIZE)
        .clipShape(Circle())
        .opacity((1 - progress) * 0.8)
        .shadow(color: Color.amber.opacity(0.5 * progress), radius: 20 * progress, x: 0, y: 0)

      // Rainbow arc
      Canvas { context, size in
        drawArc(context: context, size: size, progress: progress)
      }
      .frame(width: BUTTON_SIZE + 20, height: BUTTON_SIZE + 20)
      .shadow(color: Color.amber.opacity(0.6 * progress), radius: 12 * progress, x: 0, y: 0)

      // Center dot with glow
      Circle()
        .fill(Color.amber)
        .frame(width: 8, height: 8)
        .shadow(color: Color.amber.opacity(0.9 * progress), radius: 8 * progress, x: 0, y: 0)

      // Phase label
      if !currentPhase.isEmpty {
        Text(currentPhase)
          .font(.custom("Georgia", size: 14))
          .foregroundColor(Color.amber)
          .opacity(phaseOpacityForProgress(progress))
          .offset(y: -(BUTTON_SIZE / 2 + 20))
      }
    }
    .frame(width: BUTTON_SIZE, height: BUTTON_SIZE)
    .gesture(
      LongPressGesture(minimumDuration: 0.05)
        .onChanged { isPressing in
          if isPressing && !disabled && !isCompleted {
            startAnimation()
          }
        }
        .onEnded { _ in
          if !isCompleted {
            stopAnimation()
          }
        }
    )
    .onChange(of: progress) { newProgress in
      updatePhaseLabel(newProgress)
    }
    .transition(.movingParts.pop(Color.amber))
    .scaleEffect(isCompleted ? 0.95 : 1.0)
  }

  private func startAnimation() {
    guard !isHolding && !isCompleted else { return }
    isHolding = true
    progress = 0

    let startTime = Date()
    var displayLink: Timer? = nil

    displayLink = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
      let elapsed = Date().timeIntervalSince(startTime)
      let newProgress = min(CGFloat(elapsed / ANIMATION_DURATION), 1.0)

      DispatchQueue.main.async {
        progress = newProgress
        if newProgress >= 1.0 {
          timer.invalidate()
          completeAnimation()
        }
      }
    }

    // Ensure timer runs during scrolling
    RunLoop.main.add(displayLink!, forMode: .common)
  }

  private func stopAnimation() {
    isHolding = false
    withAnimation(.easeOut(duration: 0.3)) {
      progress = 0
      currentPhase = ""
    }
  }

  private func completeAnimation() {
    isHolding = false
    isCompleted = true

    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

    withAnimation(.easeOut(duration: 0.2)) {
      currentPhase = ""
    }

    onArcComplete()
  }

  private func updatePhaseLabel(_ progress: CGFloat) {
    let phases: [(threshold: CGFloat, label: String)] = [
      (0.0, "Noticing"),
      (0.333, "Reading"),
      (0.667, "Recognising"),
      (1.0, ""),
    ]

    var newLabel = ""
    for i in 0..<phases.count {
      if progress >= phases[i].threshold {
        newLabel = phases[i].label
      }
    }

    if newLabel != currentPhase {
      currentPhase = newLabel
      if !newLabel.isEmpty {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
      }
    }
  }

  private func phaseOpacityForProgress(_ prog: CGFloat) -> Double {
    let phases: [(threshold: CGFloat, label: String)] = [
      (0.0, "Noticing"),
      (0.333, "Reading"),
      (0.667, "Recognising"),
      (1.0, ""),
    ]

    for i in 0..<phases.count {
      if prog >= phases[i].threshold {
        if i < phases.count - 1 {
          let nextThreshold = phases[i + 1].threshold
          let transitionStart = nextThreshold - 0.04
          if prog >= transitionStart {
            let ratio = (prog - transitionStart) / 0.04
            return Double(max(0, 1 - ratio))
          }
          return 1.0
        }
        return 0
      }
    }
    return 0
  }

  private func drawArc(context: GraphicsContext, size: CGSize, progress: CGFloat) {
    guard progress > 0 else { return }

    let centerX = size.width / 2
    let centerY = size.height / 2
    let angle = progress * 360
    let startAngle = Angle.degrees(-90)
    let endAngle = Angle.degrees(angle - 90)

    let colors = [
      Color(red: 1.0, green: 0.3, blue: 0.4),
      Color(red: 1.0, green: 0.5, blue: 0.2),
      Color(red: 1.0, green: 0.75, blue: 0.1),
      Color(red: 0.5, green: 0.85, blue: 0.3),
      Color(red: 0.2, green: 0.7, blue: 0.95),
      Color(red: 0.6, green: 0.4, blue: 0.95),
      Color(red: 0.9, green: 0.3, blue: 0.7),
      Color(red: 1.0, green: 0.3, blue: 0.5),
    ]

    let segmentCount = Int(max(1, progress * 40))

    // Glow layers
    for layer in 0..<8 {
      let layerProgress = CGFloat(layer) / 8.0
      let opacity = (1.0 - layerProgress) * 0.15

      for i in 0..<segmentCount {
        let ratio = CGFloat(i) / CGFloat(segmentCount)
        let angle1 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * ratio
        let angle2 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * (ratio + 1.0 / CGFloat(segmentCount))

        let colorIndex = Int(ratio * CGFloat(colors.count - 1))
        let color = colors[min(colorIndex, colors.count - 1)]

        var path = Path()
        path.addArc(center: CGPoint(x: centerX, y: centerY), radius: ARC_RADIUS + CGFloat(layer) * 1.2, startAngle: .degrees(angle1), endAngle: .degrees(angle2), clockwise: false)

        context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: 4 + CGFloat(layer) * 0.5)
      }
    }

    // Main arc
    for i in 0..<segmentCount {
      let ratio = CGFloat(i) / CGFloat(segmentCount)
      let angle1 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * ratio
      let angle2 = startAngle.degrees + (endAngle.degrees - startAngle.degrees) * (ratio + 1.0 / CGFloat(segmentCount))

      let colorIndex = Int(ratio * CGFloat(colors.count - 1))
      let color = colors[min(colorIndex, colors.count - 1)]

      var path = Path()
      path.addArc(center: CGPoint(x: centerX, y: centerY), radius: ARC_RADIUS, startAngle: .degrees(angle1), endAngle: .degrees(angle2), clockwise: false)

      context.stroke(path, with: .color(color), lineWidth: 3)
    }
  }
}

struct BlurView: UIViewRepresentable {
  let style: UIBlurEffect.Style

  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: UIBlurEffect(style: style))
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
