struct DeleteTripUseCaseImpl: DeleteTripUseCase {
  private let tripRepository: TripRepository

  init(tripRepository: TripRepository) {
    self.tripRepository = tripRepository
  }

  func execute(request: Trip) {
    tripRepository.remove(request)
  }
}
