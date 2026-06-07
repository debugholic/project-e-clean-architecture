import Combine
import Foundation

/// 인메모리 일정 저장소. @Published 배열을 publisher로 노출한다.
final class InMemoryTripRepository: TripRepository {
  @Published private var trips: [Trip] = []

  var tripsPublisher: AnyPublisher<[Trip], Never> { $trips.eraseToAnyPublisher() }

  func add(_ trip: Trip) {
    trips.append(trip)
  }

  func remove(_ trip: Trip) {
    trips.removeAll { $0.id == trip.id }
  }
}
