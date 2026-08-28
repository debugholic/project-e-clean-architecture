import Foundation

nonisolated struct NetworkServiceImpl: NetworkService {
  private let config: NetworkConfigurable
  private let sessionManager: NetworkSessionManager

  init(
    config: NetworkConfigurable,
    sessionManager: NetworkSessionManager = NetworkSessionManagerImpl()
  ) {
    self.config = config
    self.sessionManager = sessionManager
  }

  func request(
    endpoint: Requestable
  ) async throws -> Data {
    let urlRequest = try endpoint.urlRequest(
      with: config
    )

    let (data, response) = try await sessionManager.data(
      for: urlRequest
    )
    try Task.checkCancellation()

    guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
    guard (200..<300).contains(
      http.statusCode
    ) else {
      throw NetworkError.statusCode(
        http.statusCode,
        data
      )
    }
    return data
  }
}
