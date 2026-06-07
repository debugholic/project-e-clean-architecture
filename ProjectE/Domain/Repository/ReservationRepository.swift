import Foundation

nonisolated enum ReservationError: LocalizedError {
  case missingAPIKey
  case notFound
  case requestFailed

  var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      return "RapidAPI 키가 없어요. Secrets.local.xcconfig에 키를 넣어주세요."
    case .notFound:
      return "해당 편명·날짜의 항공편을 찾지 못했어요."
    case .requestFailed:
      return "조회에 실패했어요. 잠시 후 다시 시도해 주세요."
    }
  }
}

/// 항공편 조회 추상화 (Domain). 구현은 Data 계층이 제공한다.
protocol ReservationRepository {
  nonisolated func fetchFlight(flightNumber: String, date: Date) async throws -> FlightLeg
}
