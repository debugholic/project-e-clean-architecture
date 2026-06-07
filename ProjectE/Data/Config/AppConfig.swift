import Foundation

/// 빌드 구성(xcconfig → Info.plist)에서 주입된 값을 읽는다.
nonisolated enum AppConfig {
  /// RapidAPI 키. Config.xcconfig 의 `RAPIDAPI_KEY`(= Secrets.local.xcconfig)에서 주입된다.
  static var rapidAPIKey: String {
    (Bundle.main.object(forInfoDictionaryKey: "RapidAPIKey") as? String) ?? ""
  }
}
