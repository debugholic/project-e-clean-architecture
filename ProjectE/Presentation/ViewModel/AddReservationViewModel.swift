import Combine
import Foundation

enum AddReservationState {
  case idle
  case loading
  case failed(String)
}

struct AddReservationViewModelActions: ViewModelActions {
  let didFinish: () -> Void
}

protocol AddReservationViewModelInput: ViewModelInput {
  func cancel()
  func lookup(outboundDate: Date, outboundNumber: String, returnDate: Date?, returnNumber: String?)
}

protocol AddReservationViewModelOutput: ViewModelOutput {
  var statePublisher: AnyPublisher<AddReservationState, Never> { get }
}

typealias AddReservationViewModelType = AddReservationViewModelInput & AddReservationViewModelOutput

final class AddReservationViewModel: ViewModel, AddReservationViewModelOutput {
  @Published private(set) var state: AddReservationState = .idle
  var statePublisher: AnyPublisher<AddReservationState, Never> { $state.eraseToAnyPublisher() }

  private let createTripUseCase: any CreateTripUseCase
  let actions: AddReservationViewModelActions?
  private var task: Task<Void, Never>?

  init(actions: AddReservationViewModelActions, createTripUseCase: any CreateTripUseCase) {
    self.createTripUseCase = createTripUseCase
    self.actions = actions
  }
}

// MARK: - Input

extension AddReservationViewModel: AddReservationViewModelInput {
  func lookup(outboundDate: Date, outboundNumber: String, returnDate: Date?, returnNumber: String?) {
    let outbound = outboundNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !outbound.isEmpty else { return }
    let returnTrimmed = returnNumber?.trimmingCharacters(in: .whitespacesAndNewlines)

    task?.cancel()
    task = Task { [weak self] in
      guard let self else { return }
      state = .loading
      do {
        try await createTripUseCase.execute(
          request: CreateTripRequest(
            outboundDate: outboundDate,
            outboundNumber: outbound,
            returnDate: returnDate,
            returnNumber: returnTrimmed
          )
        )
        state = .idle
        actions?.didFinish()
      } catch is CancellationError {
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
