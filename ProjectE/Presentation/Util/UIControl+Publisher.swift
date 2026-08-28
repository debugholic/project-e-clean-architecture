import Combine
import ObjectiveC
import UIKit

extension UIControl {
  func eventPublisher(
    for events: UIControl.Event
  ) -> AnyPublisher<UIControl, Never> {
    let subject = PassthroughSubject<UIControl, Never>()
    let target = ControlEventTarget(
      subject: subject
    )
    addTarget(
      target,
      action: #selector(ControlEventTarget.handleEvent(_:)),
      for: events
    )

    var targets = objc_getAssociatedObject(self, &Self.eventTargetsKey) as? [ControlEventTarget] ?? []
    targets.append(target)
    objc_setAssociatedObject(self, &Self.eventTargetsKey, targets, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    return subject.eraseToAnyPublisher()
  }

  private nonisolated(unsafe) static var eventTargetsKey: UInt8 = 0
}

private final class ControlEventTarget: NSObject {
  private let subject: PassthroughSubject<UIControl, Never>

  init(
    subject: PassthroughSubject<UIControl, Never>
  ) {
    self.subject = subject
  }

  @objc func handleEvent(
    _ sender: UIControl
  ) {
    subject.send(sender)
  }
}
