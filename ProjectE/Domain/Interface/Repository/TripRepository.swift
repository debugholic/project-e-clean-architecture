import Combine
import Foundation

protocol TripRepository {
  var tripsPublisher: AnyPublisher<[Trip], Never> { get }
  func add(_ trip: Trip)
  func remove(_ trip: Trip)
}
