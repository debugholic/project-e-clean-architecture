import Combine
import Foundation

/// 일정 저장 추상화 (Domain). 구현은 Data 계층이 제공한다.
protocol TripRepository {
  var tripsPublisher: AnyPublisher<[Trip], Never> { get }
  func add(_ trip: Trip)
  func remove(_ trip: Trip)
}
