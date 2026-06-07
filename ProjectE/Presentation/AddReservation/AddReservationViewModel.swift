import Combine
import Foundation

final class AddReservationViewModel {

  enum State {
    case idle
    case loading
    case failed(String)
  }

  @Published private(set) var state: State = .idle

  /// 일정 생성에 성공했을 때 알린다(화면을 닫기 위해).
  var created: AnyPublisher<Void, Never> { createdSubject.eraseToAnyPublisher() }
  private let createdSubject = PassthroughSubject<Void, Never>()

  private let createTrip: CreateTripUseCase
  private var task: Task<Void, Never>?

  init(createTrip: CreateTripUseCase) {
    self.createTrip = createTrip
  }

  /// 가는 편(필수) + 오는 편(왕복일 때)을 비동기 조회해 일정을 만든다.
  func lookup(outboundNumber: String, outboundDate: Date, returnNumber: String?, returnDate: Date?) {
    let outbound = outboundNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !outbound.isEmpty else { return }
    let returnTrimmed = returnNumber?.trimmingCharacters(in: .whitespacesAndNewlines)

    task?.cancel()
    task = Task { [weak self] in
      guard let self else { return }
      state = .loading
      do {
        try await createTrip.execute(
          outboundNumber: outbound,
          outboundDate: outboundDate,
          returnNumber: returnTrimmed,
          returnDate: returnDate
        )
        state = .idle
        createdSubject.send()
      } catch is CancellationError {
        // 화면 이탈로 취소된 경우는 무시한다.
      } catch {
        let message = (error as? LocalizedError)?.errorDescription ?? "조회에 실패했어요. 다시 시도해 주세요."
        state = .failed(message)
      }
    }
  }

  func cancel() {
    task?.cancel()
  }
}
