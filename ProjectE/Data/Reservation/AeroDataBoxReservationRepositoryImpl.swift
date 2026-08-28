import Foundation

nonisolated struct AeroDataBoxReservationRepositoryImpl: ReservationRepository {
  private let networkService: NetworkService

  init(
    networkService: NetworkService
  ) {
    self.networkService = networkService
  }

  func fetchFlight(
    date: Date,
    flightNumber: String
  ) async throws -> FlightLeg {
    let number = flightNumber.trimmingCharacters(
      in: .whitespaces
    ).uppercased()
    guard !number.isEmpty else {
      throw ReservationError.notFound
    }

    let endpoint = AeroDataBoxFlightEndpoint(
      date: date,
      flightNumber: number
    )

    let data: Data
    do {
      data = try await networkService.request(
        endpoint: endpoint
      )
    } catch let error as NetworkError {
      throw reservationError(
        from: error
      )
    }

    let leg = try parse(data)
    guard leg.flightNumber.isEmpty else { return leg }

    return FlightLeg(
      airline: leg.airline,
      arrival: leg.arrival,
      departure: leg.departure,
      flightNumber: number
    )
  }

  private func reservationError(
    from error: NetworkError
  ) -> ReservationError {
    switch error.statusCode {
    case 401, 403: return .missingAPIKey
    case 404: return .notFound
    default: return .requestFailed
    }
  }

  private func parse(
    _ data: Data
  ) throws -> FlightLeg {
    let flights = try JSONDecoder().decode(
      [FlightDTO].self,
      from: data
    )
    guard let leg = flights.compactMap(
      {
        $0.toDomain()
      }).first else {
      throw ReservationError.notFound
    }
    return leg
  }
}
