import UIKit

final class AppDIContainer {
  private lazy var tripStorage: TripStorage = {
    InMemoryTripStorageImpl()
  }()
  
  private lazy var tripRepository: TripRepository = {
    TripRepositoryImpl(
      storage: tripStorage
    )
  }()
  
  private let aeroDataBoxHost = "aerodatabox.p.rapidapi.com"
  private let apiKey = AppConfig.rapidAPIKey
  
  private lazy var aeroDataBoxAPIConfig: NetworkConfigurable = {
    APIConfig(
      baseURL: URL(
        string: "https://\(aeroDataBoxHost)"
      ),
      headers: [
        "X-RapidAPI-Host": aeroDataBoxHost,
        "X-RapidAPI-Key": apiKey,
      ]
    )
  }()
  
  private lazy var aeroDataBoxNetworkService: NetworkService = {
    NetworkServiceImpl(
      config: aeroDataBoxAPIConfig
    )
  }()
  
  private lazy var reservationRepository: ReservationRepository = {
    AeroDataBoxReservationRepositoryImpl(
      networkService: aeroDataBoxNetworkService
    )
  }()
  
  // MARK: - UseCase
  
  private func makeCreateTripUseCase() -> any CreateTripUseCase {
    CreateTripUseCaseImpl(
      reservationRepository: reservationRepository,
      tripRepository: tripRepository
    )
  }
  
  private func makeDeleteTripUseCase() -> any DeleteTripUseCase {
    DeleteTripUseCaseImpl(
      tripRepository: tripRepository
    )
  }
  
  private func makeObserveTripsUseCase() -> any ObserveTripsUseCase {
    ObserveTripsUseCaseImpl(
      tripRepository: tripRepository
    )
  }
}

// MARK: - AppFlowCoordinatorDependencies

extension AppDIContainer: AppFlowCoordinatorDependencies {
  func makeTripListViewController(
    actions: TripListViewModelActions
  ) -> UIViewController {
    TripListViewController(
      viewModel: TripListViewModel(
        actions: actions,
        deleteTripUseCase: makeDeleteTripUseCase(),
        observeTripsUseCase: makeObserveTripsUseCase()
      )
    )
  }
  
  func makeAddReservationViewController(
    actions: AddReservationViewModelActions
  ) -> UIViewController {
    AddReservationViewController(
      viewModel: AddReservationViewModel(
        actions: actions,
        createTripUseCase: makeCreateTripUseCase()
      )
    )
  }
  
  func makeTripCalendarViewController(
    trip: Trip
  ) -> UIViewController {
    TripCalendarViewController(
      viewModel: TripCalendarViewModel(
        trip: trip
      )
    )
  }
}
