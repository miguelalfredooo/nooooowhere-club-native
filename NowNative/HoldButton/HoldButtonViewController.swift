import UIKit
import SwiftUI

/// Container view controller for the HoldButton interaction.
/// Hosts the SwiftUI HoldButton view.
class HoldButtonViewController: UIViewController {
  private var hostingController: UIHostingController<HoldButtonView>?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = Colors.void
    setupSwiftUIButton()
  }

  private func setupSwiftUIButton() {
    let holdButtonView = HoldButtonView(onArcComplete: { [weak self] in
      self?.handleArcComplete()
    })

    let hostingController = UIHostingController(rootView: holdButtonView)
    self.hostingController = hostingController

    addChild(hostingController)
    view.addSubview(hostingController.view)

    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.backgroundColor = Colors.void

    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    hostingController.didMove(toParent: self)
  }

  private func handleArcComplete() {
    // This will trigger when the user holds the button for 3 seconds
    print("Arc completed!")
  }
}
