import Foundation

nonisolated struct AeroDataBoxFlightEndpoint: Requestable {
  let date: Date
  let flightNumber: String

  var path: String {
    let encoded = flightNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
      ?? flightNumber
    return "flights/number/\(encoded)/\(Self.dateString(from: date))"
  }

  static func dateString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
}
