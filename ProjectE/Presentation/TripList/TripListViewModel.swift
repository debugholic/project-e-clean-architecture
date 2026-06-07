import Combine
import Foundation

final class TripListViewModel {

  @Published private(set) var trips: [Trip] = []

  private let deleteTrip: DeleteTripUseCase
  private var cancellables = Set<AnyCancellable>()

  init(observeTrips: ObserveTripsUseCase, deleteTrip: DeleteTripUseCase) {
    self.deleteTrip = deleteTrip
    observeTrips.execute()
      .sink { [weak self] trips in self?.trips = trips }
      .store(in: &cancellables)
  }

  func delete(_ trip: Trip) {
    deleteTrip.execute(trip)
  }
}
