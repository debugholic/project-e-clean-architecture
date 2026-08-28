struct CreateTripUseCaseImpl: CreateTripUseCase {
  private let reservationRepository: ReservationRepository
  private let tripRepository: TripRepository

  init(
    reservationRepository: ReservationRepository,
    tripRepository: TripRepository
  ) {
    self.reservationRepository = reservationRepository
    self.tripRepository = tripRepository
  }

  func execute(request: CreateTripRequest) async throws {
    let outbound = try await reservationRepository.fetchFlight(
      date: request.outboundDate,
      flightNumber: request.outboundNumber
    )

    var returnLeg: FlightLeg?
    if let returnNumber = request.returnNumber,
       !returnNumber.isEmpty,
       let returnDate = request.returnDate {
      returnLeg = try await reservationRepository.fetchFlight(
        date: returnDate,
        flightNumber: returnNumber
      )
    }

    tripRepository.add(Trip(outbound: outbound, returnLeg: returnLeg))
  }
}
