nonisolated struct FlightLeg: Hashable {
  let airline: String?
  let arrival: Movement
  let departure: Movement
  let flightNumber: String
}
