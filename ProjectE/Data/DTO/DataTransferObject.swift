protocol DataTransferObject: Decodable {
  associatedtype DomainType

  nonisolated func toDomain() -> DomainType
}
