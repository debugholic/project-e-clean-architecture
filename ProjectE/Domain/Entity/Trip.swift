import Foundation

nonisolated struct Trip: Hashable {
  let id: UUID
  let outbound: FlightLeg
  let returnLeg: FlightLeg?

  init(
    id: UUID = UUID(),
    outbound: FlightLeg,
    returnLeg: FlightLeg? = nil
  ) {
    self.id = id
    self.outbound = outbound
    self.returnLeg = returnLeg
  }

  var destination: Airport { outbound.arrival.airport }

  var isRoundTrip: Bool { returnLeg != nil }

  var startDate: Date { outbound.departure.scheduledTime.date }
  var endDate: Date { returnLeg?.departure.scheduledTime.date ?? startDate }

  func totalDays(
    using calendar: Calendar
  ) -> Int {
    let from = calendar.startOfDay(
      for: startDate
    )
    let to = calendar.startOfDay(
      for: endDate
    )
    let nights = calendar.dateComponents(
      [.day],
      from: from,
      to: to
    ).day ?? 0
    return nights + 1
  }
}
