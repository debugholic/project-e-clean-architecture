import Combine
import Foundation

struct TripListViewModelActions: ViewModelActions {
  let showAddReservation: () -> Void
  let showCalendar: (Trip) -> Void
}

protocol TripListViewModelInput: ViewModelInput {
  func didTapAddReservation()
  func didSelectTrip(_ trip: Trip)
  func didDeleteTrip(_ trip: Trip)
}

protocol TripListViewModelOutput: ViewModelOutput {
  var trips: [Trip] { get }
  var tripsPublisher: AnyPublisher<[Trip], Never> { get }
}

typealias TripListViewModelType = TripListViewModelInput & TripListViewModelOutput

final class TripListViewModel: ViewModel, TripListViewModelOutput {
  @Published private(set) var trips: [Trip] = []
  var tripsPublisher: AnyPublisher<[Trip], Never> { $trips.eraseToAnyPublisher() }

  private let deleteTripUseCase: any DeleteTripUseCase
  let actions: TripListViewModelActions?
  private var cancellables = Set<AnyCancellable>()

  init(
    actions: TripListViewModelActions,
    deleteTripUseCase: any DeleteTripUseCase,
    observeTripsUseCase: any ObserveTripsUseCase
  ) {
    self.deleteTripUseCase = deleteTripUseCase
    self.actions = actions

    Task { [weak self] in
      guard let self,
            let trips = try? await observeTripsUseCase.execute()
      else { return }

      trips
        .sink { [weak self] trips in self?.trips = trips }
        .store(in: &self.cancellables)
    }
  }
}

// MARK: - Input

extension TripListViewModel: TripListViewModelInput {
  func didTapAddReservation() {
    actions?.showAddReservation()
  }

  func didSelectTrip(_ trip: Trip) {
    actions?.showCalendar(trip)
  }

  func didDeleteTrip(_ trip: Trip) {
    Task { [weak self] in
      try? await self?.deleteTripUseCase.execute(request: trip)
    }
  }
}
