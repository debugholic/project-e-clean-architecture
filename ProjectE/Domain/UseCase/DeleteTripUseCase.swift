/// 일정을 삭제한다.
struct DeleteTripUseCase {
  let trips: TripRepository

  func execute(_ trip: Trip) {
    trips.remove(trip)
  }
}
