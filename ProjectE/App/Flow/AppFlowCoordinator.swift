import UIKit

@MainActor
protocol AppFlowCoordinatorDependencies {
  func makeTripListViewController(actions: TripListViewModelActions) -> UIViewController
  func makeAddReservationViewController(actions: AddReservationViewModelActions) -> UIViewController
  func makeTripCalendarViewController(trip: Trip) -> UIViewController
}

@MainActor
final class AppFlowCoordinator {
  private let navigationController: UINavigationController
  private let dependencies: AppFlowCoordinatorDependencies

  init(
    dependencies: AppFlowCoordinatorDependencies,
    navigationController: UINavigationController
  ) {
    self.dependencies = dependencies
    self.navigationController = navigationController
  }

  func start() {
    let actions = TripListViewModelActions(
      showAddReservation: { [weak self] in self?.showAddReservation() },
      showCalendar: { [weak self] trip in self?.showCalendar(trip) }
    )
    let viewController = dependencies.makeTripListViewController(actions: actions)
    navigationController.setViewControllers([viewController], animated: false)
  }

  private func showAddReservation() {
    let actions = AddReservationViewModelActions(
      didFinish: { [weak self] in self?.navigationController.popViewController(animated: true) }
    )
    let viewController = dependencies.makeAddReservationViewController(actions: actions)
    navigationController.pushViewController(viewController, animated: true)
  }

  private func showCalendar(_ trip: Trip) {
    let viewController = dependencies.makeTripCalendarViewController(trip: trip)
    navigationController.pushViewController(viewController, animated: true)
  }
}
