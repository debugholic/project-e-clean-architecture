import Foundation

/// AeroDataBox(RapidAPI) 실제 연동. GET /flights/number/{number}/{date}
nonisolated struct AeroDataBoxReservationRepository: ReservationRepository {

  private let host = "aerodatabox.p.rapidapi.com"

  func fetchFlight(flightNumber: String, date: Date) async throws -> FlightLeg {
    let key = AppConfig.rapidAPIKey
    guard !key.isEmpty else { throw ReservationError.missingAPIKey }

    let number = flightNumber.trimmingCharacters(in: .whitespaces).uppercased()
    guard !number.isEmpty,
          let encodedNumber = number.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
          let url = URL(string: "https://\(host)/flights/number/\(encodedNumber)/\(Self.dateString(from: date))")
    else {
      throw ReservationError.notFound
    }

    var request = URLRequest(url: url)
    request.setValue(key, forHTTPHeaderField: "X-RapidAPI-Key")
    request.setValue(host, forHTTPHeaderField: "X-RapidAPI-Host")

    let (data, response) = try await URLSession.shared.data(for: request)
    try Task.checkCancellation()

    guard let http = response as? HTTPURLResponse else { throw ReservationError.requestFailed }
    if http.statusCode == 404 { throw ReservationError.notFound }
    guard (200..<300).contains(http.statusCode) else { throw ReservationError.requestFailed }

    return try Self.parse(data, flightNumber: number)
  }

  // MARK: - Parsing (네트워크와 분리해 샘플 JSON으로도 검증 가능)

  static func parse(_ data: Data, flightNumber: String) throws -> FlightLeg {
    let flights = try JSONDecoder().decode([ADBFlight].self, from: data)
    guard let leg = flights.compactMap({ makeLeg(flightNumber: flightNumber, from: $0) }).first else {
      throw ReservationError.notFound
    }
    return leg
  }

  static func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }

  private static func makeLeg(flightNumber: String, from flight: ADBFlight) -> FlightLeg? {
    guard let departure = flight.departure,
          let arrival = flight.arrival,
          let departureAirport = departure.airport,
          let arrivalAirport = arrival.airport,
          let departureLocal = departure.scheduledTime?.local
    else { return nil }

    let cityName = arrivalAirport.municipalityName ?? arrivalAirport.name ?? arrivalAirport.iata ?? "도착지"
    let country = arrivalAirport.countryCode
      .flatMap { Locale(identifier: "en_US").localizedString(forRegionCode: $0) }
      ?? arrivalAirport.countryCode ?? ""

    return FlightLeg(
      flightNumber: flight.number?.replacingOccurrences(of: " ", with: "") ?? flightNumber,
      airline: flight.airline?.name ?? "Unknown",
      originCity: departureAirport.municipalityName ?? departureAirport.name ?? "",
      originCode: departureAirport.iata ?? "",
      destinationCity: cityName,
      destinationCode: arrivalAirport.iata ?? "",
      destinationCountry: country,
      date: parseDate(departureLocal) ?? Date(),
      departureTime: parseTime(departureLocal),
      arrivalTime: arrival.scheduledTime?.local.map(parseTime) ?? "--:--"
    )
  }

  private static func parseDate(_ local: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: String(local.prefix(10)))
  }

  private static func parseTime(_ local: String) -> String {
    guard local.count >= 16 else { return "--:--" }
    let start = local.index(local.startIndex, offsetBy: 11)
    let end = local.index(start, offsetBy: 5)
    return String(local[start..<end])
  }
}

// MARK: - AeroDataBox 응답 DTO (필요한 필드만, 방어적 옵셔널)

private nonisolated struct ADBFlight: Decodable {
  let number: String?
  let airline: ADBAirline?
  let departure: ADBMovement?
  let arrival: ADBMovement?
}

private nonisolated struct ADBAirline: Decodable {
  let name: String?
}

private nonisolated struct ADBMovement: Decodable {
  let airport: ADBAirport?
  let scheduledTime: ADBTime?
}

private nonisolated struct ADBAirport: Decodable {
  let iata: String?
  let name: String?
  let municipalityName: String?
  let countryCode: String?
}

private nonisolated struct ADBTime: Decodable {
  let local: String?
}
