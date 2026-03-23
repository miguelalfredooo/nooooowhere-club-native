# HoldButton Native Implementation Plan

## Overview

The HoldButton is the flagship micro-interaction of Nowhere Club. This document specifies the native iOS implementation using UIKit, Core Graphics, and CABasicAnimation to achieve perfect 60fps animation with synchronized arc fill, blur interpolation, and phase label transitions.

**Duration:** 3 seconds (3000ms) from press to completion
**Framework:** UIKit (custom UIView subclass)
**Animation Engine:** CABasicAnimation + CADisplayLink (for per-frame coordination)
**Gesture Handling:** UILongPressGestureRecognizer
**Haptic Feedback:** UIImpactFeedbackGenerator + UINotificationFeedbackGenerator

---

## Architecture Overview

```
HoldButtonViewController
  └── HoldButtonView (custom UIView)
      ├── CanvasView (CALayer-backed, arc drawing)
      ├── BlurView (dynamic blur effect)
      ├── CenterDot (UIView, fixed position)
      ├── PhaseLabel (UILabel, animated opacity/position)
      └── GestureManager (internal handler)
```

### State Machine

```
[Idle]
  ↓ (LongPressGestureRecognizer begins)
[Pressing]
  ├─→ animateArcFill() + animateBlur()
  ├─→ track arcProgress: 0 → 1 over 3000ms
  ├─→ at 0%:    show "Noticing"
  ├─→ at 33%:   fade "Noticing" → show "Reading"
  ├─→ at 67%:   fade "Reading" → show "Recognising"
  ├─→ at 100%:  haptic + dim button + fade label
  ↓ (gesture release OR timeout at 3s)
[Complete]
  └─→ trigger onArcComplete callback
  └─→ button dims (opacity 0.4)

OR

[Pressing]
  ↓ (gesture released before 100%)
[Resetting]
  └─→ reverse animations (arc shrink, blur return)
  └─→ reset to [Idle] after 300ms
```

---

## Component Structure

### 1. HoldButtonView (Custom UIView)

**Purpose:** Container holding all subviews and managing animation lifecycle.

**Properties:**
```swift
class HoldButtonView: UIView {
  private let arcCanvas = CanvasView()           // Draws circle + arc
  private let blurView = UIVisualEffectView()    // Dynamic blur
  private let centerDot = UIView()               // Amber center marker
  private let phaseLabel = UILabel()             // Animated phase text

  private var displayLink: CADisplayLink?        // For per-frame sync
  private var animationStartTime: CFTimeInterval = 0
  private var isAnimating = false
  private var isCompleted = false

  var onArcComplete: (() -> Void)?
  var disabled = false

  // Shared animation state
  private(set) var arcProgress: CGFloat = 0 {
    didSet { updateArcPath() }
  }
  private(set) var blurRadius: CGFloat = 20 {
    didSet { updateBlur() }
  }
}
```

**Key Methods:**
- `beginAnimation()` — Start press (called on gesture begin)
- `resetAnimation()` — Cancel animation (called on gesture release before 3s)
- `completeAnimation()` — Finish animation (called at 3s mark)
- `updateArcPath()` — Redraw arc based on progress
- `updateBlur()` — Update blur radius based on progress
- `updatePhaseLabel(phase:, opacity:)` — Update label text and fade

---

### 2. CanvasView (Core Graphics Arc Drawing)

**Purpose:** Draw the static circle outline and animated arc path.

```swift
class CanvasView: UIView {
  var arcProgress: CGFloat = 0 {
    didSet { setNeedsDisplay() }
  }

  let ARC_RADIUS: CGFloat = 45
  let ARC_CENTER_X: CGFloat = 50      // SVG center offset
  let ARC_CENTER_Y: CGFloat = 50

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // Static circle (faded amber outline, 2pt, 30% opacity)
    drawStaticCircle(context)

    // Animated arc (amber, 3pt, 100% opacity, round caps)
    drawAnimatedArc(context)
  }

  private func drawStaticCircle(_ context: CGContext) {
    let path = UIBezierPath(
      arcCenter: CGPoint(x: ARC_CENTER_X, y: ARC_CENTER_Y),
      radius: ARC_RADIUS,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: true
    )

    UIColor.amber.withAlphaComponent(0.3).setStroke()
    path.lineWidth = 2
    path.stroke()
  }

  private func drawAnimatedArc(_ context: CGContext) {
    let angle = arcProgress * 360  // 0 to 360 degrees
    let radians = (angle - 90) * (.pi / 180)  // Start from top

    let startAngle = CGFloat(-90 * (.pi / 180))
    let endAngle = CGFloat(radians)

    let path = UIBezierPath(
      arcCenter: CGPoint(x: ARC_CENTER_X, y: ARC_CENTER_Y),
      radius: ARC_RADIUS,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true
    )

    UIColor.amber.setStroke()
    path.lineWidth = 3
    path.lineCapStyle = .round
    path.stroke()
  }
}
```

---

### 3. Animation Pipeline (CABasicAnimation + CADisplayLink)

**Goal:** Synchronize three animations: arc rotation, blur interpolation, phase label transitions.

#### 3.1 Arc Fill Animation

```swift
func startArcAnimation() {
  // CABasicAnimation for arc progress
  let arcAnimation = CABasicAnimation(keyPath: "arcProgress")
  arcAnimation.fromValue = CGFloat(0)
  arcAnimation.toValue = CGFloat(1)
  arcAnimation.duration = 3.0  // 3 seconds
  arcAnimation.timingFunction = CAMediaTimingFunction(
    name: .easeInEaseOut
  )
  arcAnimation.fillMode = .forwards
  arcAnimation.isRemovedOnCompletion = false

  // CADisplayLink for per-frame sync
  displayLink = CADisplayLink(
    target: self,
    selector: #selector(updateAnimationFrame)
  )
  displayLink?.add(to: .main, forMode: .common)
  animationStartTime = CACurrentMediaTime()
  isAnimating = true
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
```

#### 3.2 Blur Interpolation

```swift
private func updateBlur() {
  // blurRadius: 20 (fully blurred) → 0 (sharp)
  // This is synchronized with arcProgress

  let blurEffect = UIBlurEffect(style: .dark)
  blurView.effect = blurEffect

  // Opacity interpolation (visual hack for variable blur strength)
  blurView.alpha = blurRadius / 20.0
}
```

#### 3.3 Phase Label Transitions

**Timing:**
- **0–33% (0s–1s):** "Noticing" (fade in at 0%, stay opaque)
- **33–67% (1s–2s):** Fade "Noticing" (200ms), fade in "Reading" (200ms)
- **67–100% (2s–3s):** Fade "Reading" (200ms), fade in "Recognising" (200ms)
- **100% (3s):** Fade out "Recognising" (200ms), trigger haptic

```swift
private func updatePhaseLabels(for progress: CGFloat) {
  let thresholds: [(CGFloat, String)] = [
    (0.0, "Noticing"),
    (0.333, "Reading"),
    (0.667, "Recognising"),
    (1.0, "")
  ]

  for (threshold, label) in thresholds {
    let transitionStart = threshold - 0.02
    let transitionEnd = threshold + 0.02

    if progress >= transitionStart && progress < transitionEnd {
      let transitionProgress = (progress - transitionStart) / 0.04

      if label.isEmpty {
        // Fade out existing label
        phaseLabel.alpha = max(0, 1 - transitionProgress)
      } else if phaseLabel.text != label {
        // Fade in new label
        phaseLabel.text = label
        phaseLabel.alpha = transitionProgress
      }
    }
  }
}
```

---

### 4. Gesture Handling

**UILongPressGestureRecognizer** with custom state flow:

```swift
func setupGestureRecognizer() {
  let longPress = UILongPressGestureRecognizer(
    target: self,
    action: #selector(handleLongPress(_:))
  )
  longPress.minimumPressDuration = 0.05  // 50ms to register
  addGestureRecognizer(longPress)
}

@objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
  switch gesture.state {
  case .began:
    if !disabled && !isCompleted {
      beginAnimation()
    }

  case .ended, .cancelled, .failed:
    if isAnimating && !isCompleted {
      // Gesture released before 3s
      resetAnimation()
    }

  default:
    break
  }
}
```

---

### 5. Haptic Feedback

**Two haptic moments:**

1. **At 100% completion (3s mark):**
   ```swift
   private func triggerCompletionHaptic() {
     let impact = UIImpactFeedbackGenerator(style: .heavy)
     impact.impactOccurred()
   }
   ```

2. **On reset (optional, for user feedback):**
   ```swift
   private func triggerResetNotification() {
     let notification = UINotificationFeedbackGenerator()
     notification.notificationOccurred(.warning)
   }
   ```

---

### 6. Completion State

**At 3s mark:**

```swift
private func completeAnimation() {
  displayLink?.invalidate()
  displayLink = nil
  isAnimating = false
  isCompleted = true

  // Trigger haptic
  triggerCompletionHaptic()

  // Dim button
  UIView.animate(withDuration: 0.4) {
    self.alpha = 0.4
  }

  // Fade out phase label
  UIView.animate(withDuration: 0.2) {
    self.phaseLabel.alpha = 0
  }

  // Trigger callback
  onArcComplete?()
}
```

---

### 7. Reset Animation (on early release)

```swift
private func resetAnimation() {
  displayLink?.invalidate()
  displayLink = nil
  isAnimating = false

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
    }
  )
}
```

---

## Implementation Phases

### Phase 1: Core View & Static Elements (1-2 hours)
- [ ] Create `HoldButtonView` subclass
- [ ] Add static circle (CanvasView)
- [ ] Add center dot (amber, 8pt diameter)
- [ ] Add phase label (Georgia, italic, 14pt)
- [ ] Add blur view (dark style, 20pt baseline)
- [ ] Verify visual layout matches design spec

### Phase 2: Animation Framework (2-3 hours)
- [ ] Implement `CADisplayLink` per-frame sync
- [ ] Implement arc path generation (0–360° clockwise from top)
- [ ] Implement blur interpolation (20 → 0 over 3s)
- [ ] Implement phase label transitions with timing
- [ ] Verify smooth 60fps animation

### Phase 3: Gesture & State (1-2 hours)
- [ ] Add UILongPressGestureRecognizer
- [ ] Implement state machine (idle → pressing → complete → reset)
- [ ] Implement reset flow on early release
- [ ] Test press-release-press cycle stability

### Phase 4: Haptics & Polish (1 hour)
- [ ] Add haptic feedback at completion
- [ ] Add button dim animation
- [ ] Add label fade-out animation
- [ ] Test haptic timing against animation timeline

### Phase 5: Integration & Testing (1-2 hours)
- [ ] Wire up ViewController to manage HoldButtonView
- [ ] Add disabled state handling
- [ ] Add onArcComplete callback
- [ ] Full interaction testing on device

---

## Performance Targets

- **Frame rate:** 60 FPS (no drops during 3s animation)
- **Memory footprint:** < 5MB for view hierarchy
- **Gesture latency:** < 50ms from touch to animation start
- **Battery impact:** Minimal (CADisplayLink invalidates at completion)

---

## Testing Checklist

- [ ] Single press-hold-release (full 3s) completes without crash
- [ ] Early release (< 1s) resets and allows re-press
- [ ] Rapid press-release-press cycles (stress test)
- [ ] Phase labels transition at exact timings (0s, 1s, 2s, 3s)
- [ ] Haptic triggers at exactly 3s mark
- [ ] Blur effect visible from start to end
- [ ] Arc fills smoothly and continuously
- [ ] 60 FPS maintained throughout (profile with Instruments)
- [ ] Memory stable (no leaks on repeated presses)
- [ ] Works on iPhone 12, 13, 14, 15 models

---

## Dependencies & Imports

```swift
import UIKit
import CoreGraphics
import AVFoundation  // For haptics

// Colors (from design tokens)
let COLORS_VOID = UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1.0)
let COLORS_AMBER = UIColor(red: 0.77, green: 0.57, blue: 0.16, alpha: 1.0)

// Motion tokens
let MOTION_ARC_FILL_DURATION: TimeInterval = 3.0
let MOTION_EASING = CAMediaTimingFunction(name: .easeInEaseOut)
```

---

## File Structure

```
nooooowhere-native/
├── HoldButton/
│   ├── HoldButtonView.swift        (main container view)
│   ├── CanvasView.swift            (arc drawing)
│   ├── HoldButtonViewController.swift (container VC)
│   └── HoldButton+Animation.swift  (extension with animation logic)
└── Resources/
    └── Colors.swift                (design tokens)
```

---

## Known Unknowns & Decisions

1. **Blur Effect:** UIVisualEffectView used. Alternative: Core Image filter (slower, more control).
2. **Arc Rendering:** Core Graphics (fast, simple). Alternative: CAShapeLayer (cleaner, more animated).
3. **Per-frame Sync:** CADisplayLink chosen for precision. Alternative: Timer (less reliable).
4. **Phase Transitions:** Hard-coded threshold logic. Consider: State machine abstraction if complexity grows.

---

## Success Criteria

✅ Animation runs 60 FPS without drops
✅ Arc fills exactly 360° clockwise from top
✅ Blur interpolates from 20pt → 0pt
✅ Phase labels transition at 1s, 2s, 3s marks
✅ Haptic fires at exactly 3s
✅ Reset flow works on early release
✅ No memory leaks on repeated presses
✅ Gesture latency < 50ms
✅ Works on all iPhone models (12+)
✅ Visual matches Figma design spec exactly

---

## Next Steps

1. ✅ Review this plan for completeness
2. Create Xcode project structure
3. Implement Phase 1 (Core View & Static Elements)
4. Iterate through Phases 2–5
5. Integration testing on device
6. Delivery as reference implementation

