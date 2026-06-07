import Combine
import ObjectiveC
import UIKit

extension UIControl {
  /// UIControl의 target-action 이벤트를 Combine 스트림으로 노출한다.
  /// 각 이벤트마다 컨트롤 자신을 방출하므로 호출부에서 상태를 읽어 매핑할 수 있다.
  func eventPublisher(for events: UIControl.Event) -> AnyPublisher<UIControl, Never> {
    let subject = PassthroughSubject<UIControl, Never>()
    let target = ControlEventTarget(subject: subject)
    addTarget(target, action: #selector(ControlEventTarget.handleEvent(_:)), for: events)

    // UIControl은 타깃을 unowned로 참조하므로, 컨트롤 수명 동안 타깃을 직접 붙들어 둔다.
    var targets = objc_getAssociatedObject(self, &Self.eventTargetsKey) as? [ControlEventTarget] ?? []
    targets.append(target)
    objc_setAssociatedObject(self, &Self.eventTargetsKey, targets, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    return subject.eraseToAnyPublisher()
  }

  private nonisolated(unsafe) static var eventTargetsKey: UInt8 = 0
}

private final class ControlEventTarget: NSObject {
  private let subject: PassthroughSubject<UIControl, Never>

  init(subject: PassthroughSubject<UIControl, Never>) {
    self.subject = subject
  }

  @objc func handleEvent(_ sender: UIControl) {
    subject.send(sender)
  }
}
