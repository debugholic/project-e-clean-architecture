import Combine

final class InMemoryTripStorageImpl: TripStorage {
  @Published private var trips: [Trip] = []

  var tripsPublisher: AnyPublisher<[Trip], Never> { $trips.eraseToAnyPublisher() }

  func save(
    _ trip: Trip
  ) {
    trips.append(
      trip
    )
  }

  func delete(
    _ trip: Trip
  ) {
    trips.removeAll {
      $0.id == trip.id
    }
  }
}
