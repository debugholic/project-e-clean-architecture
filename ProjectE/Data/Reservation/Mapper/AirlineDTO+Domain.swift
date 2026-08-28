extension AirlineDTO: DataTransferObject {
  nonisolated func toDomain() -> String? {
    name
  }
}
