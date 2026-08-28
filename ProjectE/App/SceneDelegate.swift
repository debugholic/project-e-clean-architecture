import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private let container = AppDIContainer()
  private var flowCoordinator: AppFlowCoordinator?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    
    let navigationController = UINavigationController()
    let flowCoordinator = AppFlowCoordinator(
      dependencies: container,
      navigationController: navigationController
    )
    flowCoordinator.start()
    self.flowCoordinator = flowCoordinator
    
    let window = UIWindow(
      windowScene: windowScene
    )
    window.rootViewController = navigationController
    window.makeKeyAndVisible()
    self.window = window
  }
}
