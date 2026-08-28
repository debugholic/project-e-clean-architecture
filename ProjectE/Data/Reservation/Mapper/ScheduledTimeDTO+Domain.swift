import Foundation

extension ScheduledTimeDTO: DataTransferObject {
  nonisolated func toDomain() -> ScheduledTime? {
    guard let date = parsedDate else { return nil }
    return ScheduledTime(date: date, time: parsedTime)
  }

  private nonisolated var parsedDate: Date? {
    guard let local else { return nil }
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: String(local.prefix(10)))
  }

  private nonisolated var parsedTime: String? {
    guard let local, local.count >= 16 else { return nil }
    let start = local.index(local.startIndex, offsetBy: 11)
    let end = local.index(start, offsetBy: 5)
    return String(local[start..<end])
  }
}
