import Combine
import Foundation

/// 생성된 일정의 기간을 달력에 보여주는 읽기 전용 ViewModel.
final class TripCalendarViewModel {

  let trip: Trip

  @Published private(set) var days: [CalendarDay] = []
  @Published private(set) var currentMonth: Date

  private let calendar: Calendar

  init(trip: Trip, calendar: Calendar = .current) {
    self.trip = trip
    var cal = calendar
    cal.locale = Locale(identifier: "en_US")
    self.calendar = cal
    self.currentMonth = cal.startOfMonth(for: trip.startDate)
    rebuildDays()
  }

  var summaryText: String { TripFormatter.summary(trip, calendar: calendar) }
  var flightText: String { TripFormatter.calendarFlightText(trip) }

  var monthTitle: AnyPublisher<String, Never> {
    $currentMonth
      .map { month in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: month)
      }
      .eraseToAnyPublisher()
  }

  var yearTitle: AnyPublisher<String, Never> {
    $currentMonth
      .map { [calendar] month in "\(calendar.component(.year, from: month))" }
      .eraseToAnyPublisher()
  }

  func goToPreviousMonth() {
    guard let prev = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
    currentMonth = prev
    rebuildDays()
  }

  func goToNextMonth() {
    guard let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
    currentMonth = next
    rebuildDays()
  }

  func rangeState(for day: CalendarDay) -> CalendarDayCell.RangeState {
    guard day.isInCurrentMonth else { return .none }
    let date = calendar.startOfDay(for: day.date)
    let start = calendar.startOfDay(for: trip.startDate)
    let end = calendar.startOfDay(for: trip.endDate)

    if start == end { return date == start ? .single : .none }
    if date == start { return .start }
    if date == end { return .end }
    return (date > start && date < end) ? .middle : .none
  }

  private func rebuildDays() {
    let startOfMonth = calendar.startOfMonth(for: currentMonth)
    guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
      days = []
      return
    }

    let firstWeekday = calendar.component(.weekday, from: startOfMonth)
    let leadingEmpty = firstWeekday - calendar.firstWeekday

    var result: [CalendarDay] = []
    let today = calendar.startOfDay(for: Date())

    for i in 0..<leadingEmpty {
      guard let date = calendar.date(byAdding: .day, value: -(leadingEmpty - i), to: startOfMonth) else { continue }
      let dayNumber = calendar.component(.day, from: date)
      result.append(CalendarDay(
        date: date,
        dayNumber: dayNumber,
        isInCurrentMonth: false,
        isToday: calendar.isDate(date, inSameDayAs: today)
      ))
    }

    for day in range {
      guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
      result.append(CalendarDay(
        date: date,
        dayNumber: day,
        isInCurrentMonth: true,
        isToday: calendar.isDate(date, inSameDayAs: today)
      ))
    }

    let trailing = max(0, 42 - result.count)
    for _ in 0..<trailing {
      guard let lastDate = result.last?.date,
            let date = calendar.date(byAdding: .day, value: 1, to: lastDate) else { continue }
      let dayNumber = calendar.component(.day, from: date)
      result.append(CalendarDay(
        date: date,
        dayNumber: dayNumber,
        isInCurrentMonth: false,
        isToday: calendar.isDate(date, inSameDayAs: today)
      ))
    }

    days = result
  }
}

private extension Calendar {
  func startOfMonth(for date: Date) -> Date {
    let components = dateComponents([.year, .month], from: date)
    return self.date(from: components) ?? date
  }
}
