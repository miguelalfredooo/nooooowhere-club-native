# Nowhere Club Native iOS — Setup Guide

This is a native iOS implementation of the HoldButton interaction using UIKit and Core Graphics.

## Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- iOS 13.0+ deployment target

## Project Structure

```
nooooowhere-club-native/
├── NowNative/
│   ├── HoldButton/
│   │   ├── HoldButtonView.swift
│   │   ├── CanvasView.swift
│   │   └── HoldButtonViewController.swift
│   ├── Resources/
│   │   └── Colors.swift
│   └── Supporting/
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       └── Info.plist
├── HOLDBUTTON_IMPLEMENTATION_PLAN.md
└── SETUP.md (this file)
```

## Setup Instructions

### Option 1: Create Xcode Project Manually (Recommended)

1. Open Xcode
2. Create a new iOS App project:
   - **Product Name:** `Nowhere`
   - **Team:** Personal Team (or your team)
   - **Organization Identifier:** `club.nowhere`
   - **Bundle Identifier:** `club.nowhere.app`
   - **Language:** Swift
   - **User Interface:** Storyboards (or SwiftUI, doesn't matter)
   - **Storage:** None required
   - **Uncheck:** Core Data, CloudKit, Unit Tests, UI Tests

3. Replace the generated files with ours:
   - Delete `AppDelegate.swift`, `SceneDelegate.swift` from Xcode project
   - Add our `AppDelegate.swift` and `SceneDelegate.swift` from `NowNative/Supporting/`
   - Replace `Info.plist` with ours
   - Create a group `HoldButton` and add:
     - `HoldButtonView.swift`
     - `CanvasView.swift`
     - `HoldButtonViewController.swift`
   - Create a group `Resources` and add:
     - `Colors.swift`

4. Build and run on simulator or device

### Option 2: Create via Shell Script

```bash
cd nooooowhere-club-native
chmod +x create_project.sh
./create_project.sh
```

(Script not yet created — Option 1 is easier for now)

## Verification

Once the project is set up:

1. Build the project (`Cmd+B`)
2. Run on simulator or device (`Cmd+R`)
3. You should see a dark (void) background with an amber button at the bottom
4. The button should:
   - Have a circular outline with a center dot
   - Display "Noticing" when you press and hold (0% → 33%)
   - Transition to "Reading" at 33% (1 second)
   - Transition to "Recognising" at 67% (2 seconds)
   - Dim and complete at 100% (3 seconds)
   - Reset if you release early

## Development

The HoldButton implementation follows this structure:

- **CanvasView:** Core Graphics drawing of arc and circle
- **HoldButtonView:** Main container managing animation state and gestures
- **HoldButtonViewController:** Wraps HoldButtonView in a view controller
- **Colors:** Design tokens (amber, void, parchment, etc.)
- **AppDelegate/SceneDelegate:** Standard iOS app setup

## Phases

### Phase 1: Core View & Static Elements ✅
- [x] Create HoldButtonView subclass
- [x] Add static circle (CanvasView)
- [x] Add center dot
- [x] Add phase label
- [x] Add blur view
- [x] Add gesture recognizer
- [ ] Verify visual layout

### Phase 2: Animation Framework
- [ ] Implement CADisplayLink per-frame sync
- [ ] Implement arc path generation
- [ ] Implement blur interpolation
- [ ] Test 60 FPS animation

### Phase 3: Gesture & State
- [ ] Test state machine
- [ ] Test reset on early release
- [ ] Stress test rapid presses

### Phase 4: Haptics & Polish
- [ ] Add haptic feedback
- [ ] Add dim animation
- [ ] Add label fade-out

### Phase 5: Integration & Testing
- [ ] Wire up callbacks
- [ ] Test on device
- [ ] Profile performance

## Next Steps

1. Set up Xcode project (Option 1)
2. Build and verify Phase 1 layout
3. Run on device to check visual appearance
4. Proceed to Phase 2 (animation)
