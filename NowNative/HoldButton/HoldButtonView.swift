import UIKit
import AVFoundation
// import Pow  // TODO: Fix product name resolution

/// Main HoldButton view container. Manages:
/// - Arc canvas (Core Graphics drawing)
/// - Blur effect (dynamic opacity)
/// - Center dot (amber marker)
/// - Phase label (text with opacity animation)
/// - Gesture recognition and state management
/// - Haptic feedback at key moments
class HoldButtonView: UIView {
  // MARK: - Configuration

  private let BUTTON_SIZE: CGFloat = 80
  private let ARC_RADIUS: CGFloat = 45
  private let ANIMATION_DURATION: TimeInterval = 3.0

  // MARK: - Subviews

  private let arcCanvas = CanvasView()
  private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
  private let centerDot = UIView()
  private let phaseLabel = UILabel()

  // MARK: - State

  private var displayLink: CADisplayLink?
  private var animationStartTime: CFTimeInterval = 0
  private var isAnimating = false
  private(set) var isCompleted = false

  private var lastPhaseLabel: String = ""

  private(set) var arcProgress: CGFloat = 0 {
    didSet { updateArcPath() }
  }

  private(set) var blurRadius: CGFloat = 20 {
    didSet { updateBlur() }
  }

  // MARK: - Public Properties

  var onArcComplete: (() -> Void)?
  var disabled = false

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
    setupButton()
    setupBlurView()
    setupArcCanvas()
    setupCenterDot()
    setupPhaseLabel()
    setupGestureRecognizer()
  }

  // MARK: - Subview Setup

  private func setupButton() {
    backgroundColor = Colors.void
    layer.cornerRadius = BUTTON_SIZE / 2
    layer.borderWidth = 1
    layer.borderColor = Colors.amber.cgColor
    layer.opacity = 0.7

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: BUTTON_SIZE),
      heightAnchor.constraint(equalToConstant: BUTTON_SIZE),
    ])
  }

  private func setupBlurView() {
    blurView.layer.cornerRadius = BUTTON_SIZE / 2
    blurView.clipsToBounds = false  // Allow glow to extend beyond button
    blurView.alpha = 1.0  // Start fully blurred

    addSubview(blurView)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      blurView.topAnchor.constraint(equalTo: topAnchor),
      blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
      blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  private func setupArcCanvas() {
    let canvasSize: CGFloat = BUTTON_SIZE + 20
    arcCanvas.frame = CGRect(
      x: (BUTTON_SIZE - canvasSize) / 2,
      y: (BUTTON_SIZE - canvasSize) / 2,
      width: canvasSize,
      height: canvasSize
    )

    addSubview(arcCanvas)
  }

  private func setupCenterDot() {
    centerDot.backgroundColor = Colors.amber
    centerDot.layer.cornerRadius = 4
    centerDot.clipsToBounds = true

    addSubview(centerDot)
    centerDot.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      centerDot.widthAnchor.constraint(equalToConstant: 8),
      centerDot.heightAnchor.constraint(equalToConstant: 8),
      centerDot.centerXAnchor.constraint(equalTo: centerXAnchor),
      centerDot.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  private func setupPhaseLabel() {
    phaseLabel.text = ""
    phaseLabel.font = UIFont(name: "Georgia", size: 14)
    phaseLabel.textColor = Colors.amber
    phaseLabel.alpha = 0

    addSubview(phaseLabel)
    phaseLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      phaseLabel.bottomAnchor.constraint(equalTo: topAnchor, constant: -12),
      phaseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
    ])
  }

  // MARK: - Gesture Recognition

  private func setupGestureRecognizer() {
    let longPress = UILongPressGestureRecognizer(
      target: self,
      action: #selector(handleLongPress(_:))
    )
    longPress.minimumPressDuration = 0.05  // 50ms to register
    addGestureRecognizer(longPress)
  }

  @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      if !disabled && !isCompleted {
        beginAnimation()
      }

    case .ended, .cancelled, .failed:
      if isAnimating && !isCompleted {
        resetAnimation()
      }

    default:
      break
    }
  }

  // MARK: - Animation Control

  func beginAnimation() {
    isAnimating = true
    displayLink = CADisplayLink(
      target: self,
      selector: #selector(updateAnimationFrame)
    )
    displayLink?.add(to: .main, forMode: .common)
    animationStartTime = CACurrentMediaTime()
  }

  @objc private func updateAnimationFrame() {
    let elapsed = CACurrentMediaTime() - animationStartTime
    let progress = min(elapsed / 3.0, 1.0)

    arcProgress = progress
    blurRadius = 20 - (progress * 20)  // 20 → 0

    updatePhaseLabels(for: progress)

    if progress >= 1.0 {
      completeAnimation()
    }
  }

  private func completeAnimation() {
    displayLink?.invalidate()
    displayLink = nil
    isAnimating = false
    isCompleted = true

    // Trigger completion haptic (heavy impact)
    triggerCompletionHaptic()

    // Dim button
    UIView.animate(withDuration: 0.4) {
      self.layer.opacity = 0.4
    }

    // Fade out phase label
    UIView.animate(withDuration: 0.2) {
      self.phaseLabel.alpha = 0
    }

    // Trigger callback
    onArcComplete?()
  }

  private func resetAnimation() {
    displayLink?.invalidate()
    displayLink = nil
    isAnimating = false
    lastPhaseLabel = ""

    // Reverse animations
    UIView.animate(
      withDuration: 0.3,
      animations: {
        self.arcProgress = 0
        self.blurRadius = 20
        self.phaseLabel.alpha = 0
      },
      completion: { _ in
        self.isCompleted = false
        self.layer.opacity = 0.7  // Reset button opacity
      }
    )
  }

  // MARK: - Arc Path Update

  private func updateArcPath() {
    arcCanvas.arcProgress = arcProgress
  }

  // MARK: - Blur Update

  private func updateBlur() {
    // blurRadius: 20 (fully blurred) → 0 (sharp)
    // Opacity interpolation: visual blur strength
    blurView.alpha = blurRadius / 20.0
  }

  // MARK: - Phase Label Updates

  private func updatePhaseLabels(for progress: CGFloat) {
    let phases: [(threshold: CGFloat, label: String)] = [
      (0.0, "Noticing"),
      (0.333, "Reading"),
      (0.667, "Recognising"),
      (1.0, ""),
    ]

    // Determine current phase and transition state
    var currentLabel = ""
    var targetAlpha: CGFloat = 0

    for i in 0..<phases.count {
      let (threshold, label) = phases[i]

      if progress >= threshold {
        currentLabel = label

        // If we're at the transition point, fade out
        if i < phases.count - 1 {
          let nextThreshold = phases[i + 1].threshold
          let transitionStart = nextThreshold - 0.04  // 200ms transition window

          if progress >= transitionStart {
            // Fade out
            let transitionProgress = (progress - transitionStart) / 0.04
            targetAlpha = max(0, 1 - transitionProgress)
          } else {
            // Stable display
            targetAlpha = 1.0
          }
        } else {
          targetAlpha = 0  // Final phase (empty label)
        }
      }
    }

    // Update label if it changed
    if currentLabel != lastPhaseLabel {
      phaseLabel.text = currentLabel
      lastPhaseLabel = currentLabel
      targetAlpha = currentLabel.isEmpty ? 0 : 1.0

      // Trigger haptic at phase transitions (except empty label)
      if !currentLabel.isEmpty {
        triggerPhaseTransitionHaptic()
      }
    }

    // Smoothly update alpha
    phaseLabel.alpha = targetAlpha
  }

  // MARK: - Haptic Feedback

  private func triggerCompletionHaptic() {
    let impact = UIImpactFeedbackGenerator(style: .heavy)
    impact.impactOccurred()
  }

  private func triggerPhaseTransitionHaptic() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
  }
}
