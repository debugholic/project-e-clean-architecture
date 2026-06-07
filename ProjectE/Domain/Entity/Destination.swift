import Foundation

nonisolated struct Destination: Hashable {
  let name: String
  let country: String
}

extension Destination {
  static let samples: [Destination] = [
    Destination(name: "Tokyo", country: "Japan"),
    Destination(name: "Paris", country: "France"),
    Destination(name: "New York", country: "USA"),
    Destination(name: "Jeju", country: "South Korea"),
    Destination(name: "Bangkok", country: "Thailand"),
    Destination(name: "Rome", country: "Italy"),
    Destination(name: "Bali", country: "Indonesia"),
    Destination(name: "Sydney", country: "Australia")
  ]
}
