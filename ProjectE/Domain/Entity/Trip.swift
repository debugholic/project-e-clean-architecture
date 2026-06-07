import Foundation

/// 여행 일정 — 가는 편(필수) + 오는 편(왕복일 때). 순수 도메인(표시 문자열은 Presentation 담당).
nonisolated struct Trip: Hashable {
  let id: UUID
  let outbound: FlightLeg
  let returnLeg: FlightLeg?

  init(id: UUID = UUID(), outbound: FlightLeg, returnLeg: FlightLeg? = nil) {
    self.id = id
    self.outbound = outbound
    self.returnLeg = returnLeg
  }

  var destination: Destination {
    Destination(name: outbound.destinationCity, country: outbound.destinationCountry)
  }

  var isRoundTrip: Bool { returnLeg != nil }

  var startDate: Date { outbound.date }
  var endDate: Date { returnLeg?.date ?? outbound.date }

  func totalDays(using calendar: Calendar) -> Int {
    let from = calendar.startOfDay(for: startDate)
    let to = calendar.startOfDay(for: endDate)
    let nights = calendar.dateComponents([.day], from: from, to: to).day ?? 0
    return nights + 1
  }
}
