import Combine

/// 저장된 일정 목록을 구독한다.
struct ObserveTripsUseCase {
  let trips: TripRepository

  func execute() -> AnyPublisher<[Trip], Never> {
    trips.tripsPublisher
  }
}
