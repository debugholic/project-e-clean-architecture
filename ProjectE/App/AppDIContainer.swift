import UIKit

/// 컴포지션 루트 — Repository → UseCase → ViewModel/ViewController를 조립한다.
/// 인메모리 저장소를 단일 인스턴스로 공유한다.
final class AppDIContainer {

  private let tripRepository: TripRepository = InMemoryTripRepository()
  private let reservationRepository: ReservationRepository = AeroDataBoxReservationRepository()

  func makeTripListViewController() -> UIViewController {
    let viewModel = TripListViewModel(
      observeTrips: ObserveTripsUseCase(trips: tripRepository),
      deleteTrip: DeleteTripUseCase(trips: tripRepository)
    )
    let viewController = TripListViewController(viewModel: viewModel)
    viewController.makeAddReservation = { [weak self] in
      self?.makeAddReservationViewController() ?? UIViewController()
    }
    viewController.makeCalendar = { trip in
      TripCalendarViewController(viewModel: TripCalendarViewModel(trip: trip))
    }
    return viewController
  }

  private func makeAddReservationViewController() -> UIViewController {
    let viewModel = AddReservationViewModel(
      createTrip: CreateTripUseCase(reservation: reservationRepository, trips: tripRepository)
    )
    return AddReservationViewController(viewModel: viewModel)
  }
}
