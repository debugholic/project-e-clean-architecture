import Combine

struct ObserveTripsUseCaseImpl: ObserveTripsUseCase {
  private let tripRepository: TripRepository

  init(tripRepository: TripRepository) {
    self.tripRepository = tripRepository
  }

  func execute(request: Void) -> AnyPublisher<[Trip], Never> {
    tripRepository.tripsPublisher
  }
}
