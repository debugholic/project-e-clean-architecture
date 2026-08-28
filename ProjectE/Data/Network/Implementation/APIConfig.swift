import Foundation

nonisolated struct APIConfig: NetworkConfigurable {
  let baseURL: URL?
  let headers: [String: String]
  let queryParameters: [String: String]
  let timeoutInterval: TimeInterval

  init(
    baseURL: URL?,
    headers: [String: String] = [:],
    queryParameters: [String: String] = [:],
    timeoutInterval: TimeInterval = 30
  ) {
    self.baseURL = baseURL
    self.headers = headers
    self.queryParameters = queryParameters
    self.timeoutInterval = timeoutInterval
  }
}
