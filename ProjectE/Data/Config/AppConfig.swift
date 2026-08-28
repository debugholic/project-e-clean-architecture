import Foundation

nonisolated enum AppConfig {
  static var rapidAPIKey: String {
    (
      Bundle.main.object(
        forInfoDictionaryKey: "RapidAPIKey"
      ) as? String
    ) ?? ""
  }
}
