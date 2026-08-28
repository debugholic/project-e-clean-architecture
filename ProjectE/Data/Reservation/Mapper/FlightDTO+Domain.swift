import Foundation

extension FlightDTO: DataTransferObject {
  nonisolated func toDomain() -> FlightLeg? {
    guard let departure = departure.flatMap({ $0.toDomain() }),
          let arrival = arrival.flatMap({ $0.toDomain() })
    else { return nil }

    return FlightLeg(
      airline: airline.flatMap { $0.toDomain() },
      arrival: arrival,
      departure: departure,
      flightNumber: number?.replacingOccurrences(of: " ", with: "") ?? ""
    )
  }
}
