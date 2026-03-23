import UIKit

/// Container view controller for the HoldButton interaction.
/// Manages the layout and demonstrates the hold button in context.
class HoldButtonViewController: UIViewController {
  private let holdButton = HoldButtonView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.void
    setupHoldButton()
    setupCallbacks()
  }

  private func setupHoldButton() {
    holdButton.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(holdButton)

    NSLayoutConstraint.activate([
      holdButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      holdButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
    ])
  }

  private func setupCallbacks() {
    holdButton.onArcComplete = { [weak self] in
      self?.handleArcComplete()
    }
  }

  private func handleArcComplete() {
    // This will trigger when the user holds the button for 3 seconds
    print("Arc completed!")
  }
}
