import Foundation

nonisolated enum TripFormatter {
  private static let unknownAirline = "Unknown"
  private static let unknownCity = "도착지"
  private static let unknownTime = "--:--"

  static func summary(
    _ trip: Trip,
    calendar: Calendar
  ) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d"

    let destination = cityName(trip.destination)
    guard trip.isRoundTrip else {
      return "\(destination) · \(formatter.string(from: trip.startDate))"
    }
    let range = "\(formatter.string(from: trip.startDate)) – \(formatter.string(from: trip.endDate))"
    let total = trip.totalDays(using: calendar)
    if total <= 1 { return "\(destination) · \(range)" }
    return "\(destination) · \(total - 1)박 \(total)일 (\(range))"
  }

  static func cityName(
    _ airport: Airport
  ) -> String {
    airport.city ?? airport.code ?? unknownCity
  }

  static func legLabel(
    _ leg: FlightLeg
  ) -> String {
    let airline = leg.airline ?? unknownAirline
    let origin = leg.departure.airport.code ?? ""
    let destination = leg.arrival.airport.code ?? ""
    let departure = leg.departure.scheduledTime.time ?? unknownTime
    let arrival = leg.arrival.scheduledTime.time ?? unknownTime
    return "\(airline) \(leg.flightNumber) · \(origin) → \(destination) \(departure)–\(arrival)"
  }

  static func listFlightText(_ trip: Trip) -> String {
    trip.isRoundTrip ? "\(legLabel(trip.outbound))  ⇄ 왕복" : legLabel(trip.outbound)
  }

  static func calendarFlightText(_ trip: Trip) -> String {
    guard let returnLeg = trip.returnLeg else { return legLabel(trip.outbound) }
    return "가는 편  \(legLabel(trip.outbound))\n오는 편  \(legLabel(returnLeg))"
  }
}
