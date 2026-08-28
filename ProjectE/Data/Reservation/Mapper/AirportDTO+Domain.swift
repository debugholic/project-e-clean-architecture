import Foundation

extension AirportDTO: DataTransferObject {
  nonisolated func toDomain() -> Airport {
    Airport(
      city: municipalityName ?? name,
      code: iata,
      country: countryCode.flatMap { Locale(identifier: "en_US").localizedString(forRegionCode: $0) }
        ?? countryCode
    )
  }
}
