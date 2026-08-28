import Foundation

protocol NetworkService: Sendable {
  nonisolated func request(
    endpoint: Requestable
  ) async throws -> Data
}
