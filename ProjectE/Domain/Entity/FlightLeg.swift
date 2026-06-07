import Foundation

/// 조회된 항공편 1편(구간) — 순수 도메인 데이터.
nonisolated struct FlightLeg: Hashable {
  let flightNumber: String
  let airline: String
  let originCity: String
  let originCode: String        // 출발 공항 IATA
  let destinationCity: String
  let destinationCode: String   // 도착 공항 IATA
  let destinationCountry: String
  let date: Date                // 출발 로컬 날짜
  let departureTime: String     // "09:00"
  let arrivalTime: String       // "11:30"
}
