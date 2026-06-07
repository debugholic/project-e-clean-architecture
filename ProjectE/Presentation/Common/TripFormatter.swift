import Foundation

/// 도메인 Trip/FlightLeg을 화면 문자열로 변환 (표시 전용 — Presentation).
nonisolated enum TripFormatter {

  /// 편도: "Tokyo · Jun 10" / 왕복: "Tokyo · 5박 6일 (Jun 10 – Jun 15)"
  static func summary(_ trip: Trip, calendar: Calendar) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMM d"

    guard trip.isRoundTrip else {
      return "\(trip.destination.name) · \(formatter.string(from: trip.startDate))"
    }
    let range = "\(formatter.string(from: trip.startDate)) – \(formatter.string(from: trip.endDate))"
    let total = trip.totalDays(using: calendar)
    if total <= 1 { return "\(trip.destination.name) · \(range)" }
    return "\(trip.destination.name) · \(total - 1)박 \(total)일 (\(range))"
  }

  /// "Korean Air KE705 · ICN → NRT 09:00–11:30"
  static func legLabel(_ leg: FlightLeg) -> String {
    "\(leg.airline) \(leg.flightNumber) · \(leg.originCode) → \(leg.destinationCode) \(leg.departureTime)–\(leg.arrivalTime)"
  }

  /// 목록 셀 보조 텍스트 — 가는 편 + 왕복 표시.
  static func listFlightText(_ trip: Trip) -> String {
    trip.isRoundTrip ? "\(legLabel(trip.outbound))  ⇄ 왕복" : legLabel(trip.outbound)
  }

  /// 달력 하단 — 편도면 한 줄, 왕복이면 가는 편/오는 편 두 줄.
  static func calendarFlightText(_ trip: Trip) -> String {
    guard let returnLeg = trip.returnLeg else { return legLabel(trip.outbound) }
    return "가는 편  \(legLabel(trip.outbound))\n오는 편  \(legLabel(returnLeg))"
  }
}
