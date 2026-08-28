import Combine

final class TripRepositoryImpl: TripRepository {
  private let storage: TripStorage

  init(
    storage: TripStorage
  ) {
    self.storage = storage
  }

  var tripsPublisher: AnyPublisher<[Trip], Never> { storage.tripsPublisher }

  func add(
    _ trip: Trip
  ) {
    storage.save(
      trip
    )
  }
  
  func remove(
    _ trip: Trip
  ) {
    storage.delete(
      trip
    )
  }
}
