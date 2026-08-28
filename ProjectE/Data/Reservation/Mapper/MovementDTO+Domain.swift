extension MovementDTO: DataTransferObject {
  nonisolated func toDomain() -> Movement? {
    guard let airport,
          let scheduledTime = scheduledTime.flatMap({ $0.toDomain() })
    else { return nil }

    return Movement(
      airport: airport.toDomain(),
      scheduledTime: scheduledTime
    )
  }
}
