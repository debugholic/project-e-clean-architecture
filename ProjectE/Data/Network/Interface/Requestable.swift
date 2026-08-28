import Foundation

protocol Requestable: Sendable {
  nonisolated var path: String { get }
  nonisolated var method: HTTPMethod { get }
  nonisolated var headerParameters: [String: String] { get }
  nonisolated var queryParameters: [String: String] { get }
}

extension Requestable {
  nonisolated var method: HTTPMethod { .get }
  nonisolated var headerParameters: [String: String] { [:] }
  nonisolated var queryParameters: [String: String] { [:] }

  nonisolated func urlRequest(
    with config: NetworkConfigurable
  ) throws -> URLRequest {
    guard let baseURL = config.baseURL else { throw NetworkError.invalidURL }

    let base = baseURL.absoluteString.hasSuffix("/")
      ? baseURL.absoluteString
      : baseURL.absoluteString + "/"

    guard var components = URLComponents(
      string: base + path
    ) else {
      throw NetworkError.invalidURL
    }

    var items = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    items += config.queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    components.queryItems = items.isEmpty ? nil : items

    guard let url = components.url else { throw NetworkError.invalidURL }

    var request = URLRequest(url: url, timeoutInterval: config.timeoutInterval)
    request.httpMethod = method.rawValue
    var allHeaders = config.headers
    headerParameters.forEach { allHeaders[$0.key] = $0.value }
    request.allHTTPHeaderFields = allHeaders
    return request
  }
}
