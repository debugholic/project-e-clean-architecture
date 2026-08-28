import Combine

protocol ObserveTripsUseCase: UseCase where Request == Void, Response == AnyPublisher<[Trip], Never> {}
