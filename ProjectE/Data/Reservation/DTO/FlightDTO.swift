nonisolated struct FlightDTO: Decodable {
  let airline: AirlineDTO?
  let arrival: MovementDTO?
  let departure: MovementDTO?
  let number: String?
}
