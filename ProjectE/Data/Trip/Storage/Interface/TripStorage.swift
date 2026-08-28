import Combine

protocol TripStorage {
  var tripsPublisher: AnyPublisher<[Trip], Never> { get }
  func save(
    _ trip: Trip
  )
  func delete(
    _ trip: Trip
  )
}
