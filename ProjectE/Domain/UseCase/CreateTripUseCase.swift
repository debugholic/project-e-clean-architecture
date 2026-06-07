import Foundation

/// 가는 편(필수) + 오는 편(왕복)을 차례로 조회해 일정을 만들고 저장한다.
struct CreateTripUseCase {
  let reservation: ReservationRepository
  let trips: TripRepository

  func execute(
    outboundNumber: String,
    outboundDate: Date,
    returnNumber: String?,
    returnDate: Date?
  ) async throws {
    let outbound = try await reservation.fetchFlight(flightNumber: outboundNumber, date: outboundDate)

    var returnLeg: FlightLeg?
    if let returnNumber, !returnNumber.isEmpty, let returnDate {
      returnLeg = try await reservation.fetchFlight(flightNumber: returnNumber, date: returnDate)
    }

    trips.add(Trip(outbound: outbound, returnLeg: returnLeg))
  }
}
