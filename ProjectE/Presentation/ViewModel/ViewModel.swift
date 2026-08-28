protocol ViewModelActions {}
protocol ViewModelInput {}
protocol ViewModelOutput {}

extension Never: ViewModelActions {}

protocol ViewModel: ViewModelInput, ViewModelOutput {
  associatedtype Actions: ViewModelActions = Never

  var actions: Actions? { get }
}

extension ViewModel where Actions == Never {
  var actions: Actions? { nil }
}
