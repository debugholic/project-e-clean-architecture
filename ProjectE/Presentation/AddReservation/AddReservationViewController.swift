import Combine
import UIKit

final class AddReservationViewController: UIViewController {

  private let viewModel: AddReservationViewModel
  private var cancellables = Set<AnyCancellable>()

  private let tripTypeControl: UISegmentedControl = {
    let control = UISegmentedControl(items: ["편도", "왕복"])
    control.selectedSegmentIndex = 0
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }()

  private let outboundField = AddReservationViewController.makeField(placeholder: "가는 편 (예: KE705)")
  private let outboundDatePicker = AddReservationViewController.makeDatePicker()
  private let returnField = AddReservationViewController.makeField(placeholder: "오는 편 (예: KE706)")
  private let returnDatePicker = AddReservationViewController.makeDatePicker()

  private lazy var returnGroup = makeFlightGroup(title: "오는 편", field: returnField, datePicker: returnDatePicker)

  private let submitButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.title = "조회"
    let button = UIButton(configuration: config)
    button.isEnabled = false
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let activityIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .medium)
    view.hidesWhenStopped = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let errorLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textColor = .systemRed
    label.font = .systemFont(ofSize: 14)
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private var isRoundTrip: Bool { tripTypeControl.selectedSegmentIndex == 1 }

  init(viewModel: AddReservationViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.title = "편명으로 일정 추가"
    setupViews()
    bindViewModel()
    outboundField.becomeFirstResponder()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      viewModel.cancel()
    }
  }

  private func setupViews() {
    let hintLabel = UILabel()
    hintLabel.text = "편명과 날짜를 입력하면 실제 항공편을 조회해 일정을 만들어 드려요."
    hintLabel.numberOfLines = 0
    hintLabel.textColor = .secondaryLabel
    hintLabel.font = .systemFont(ofSize: 14)

    let outboundGroup = makeFlightGroup(title: "가는 편", field: outboundField, datePicker: outboundDatePicker)
    returnGroup.isHidden = !isRoundTrip

    let stack = UIStackView(arrangedSubviews: [
      hintLabel, tripTypeControl, outboundGroup, returnGroup, submitButton, errorLabel
    ])
    stack.axis = .vertical
    stack.spacing = 20
    stack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(stack)
    view.addSubview(activityIndicator)

    let safe = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: 20),
      stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

      activityIndicator.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 24),
      activityIndicator.centerXAnchor.constraint(equalTo: safe.centerXAnchor)
    ])
  }

  private func bindViewModel() {
    tripTypeControl.eventPublisher(for: .valueChanged)
      .sink { [weak self] _ in
        guard let self else { return }
        UIView.animate(withDuration: 0.2) { self.returnGroup.isHidden = !self.isRoundTrip }
        updateSubmitEnabled()
      }
      .store(in: &cancellables)

    for field in [outboundField, returnField] {
      field.eventPublisher(for: .editingChanged)
        .sink { [weak self] _ in self?.updateSubmitEnabled() }
        .store(in: &cancellables)
      field.eventPublisher(for: .editingDidEndOnExit)
        .sink { [weak self] _ in self?.submit() }
        .store(in: &cancellables)
    }

    submitButton.eventPublisher(for: .touchUpInside)
      .sink { [weak self] _ in self?.submit() }
      .store(in: &cancellables)

    viewModel.$state
      .sink { [weak self] state in self?.render(state) }
      .store(in: &cancellables)

    viewModel.created
      .sink { [weak self] in self?.navigationController?.popViewController(animated: true) }
      .store(in: &cancellables)
  }

  private func updateSubmitEnabled() {
    let outboundFilled = !(outboundField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    let returnFilled = !(returnField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    submitButton.isEnabled = outboundFilled && (!isRoundTrip || returnFilled)
  }

  private func submit() {
    guard submitButton.isEnabled else { return }
    view.endEditing(true)
    viewModel.lookup(
      outboundNumber: outboundField.text ?? "",
      outboundDate: outboundDatePicker.date,
      returnNumber: isRoundTrip ? returnField.text : nil,
      returnDate: isRoundTrip ? returnDatePicker.date : nil
    )
  }

  private func render(_ state: AddReservationViewModel.State) {
    let loading = { if case .loading = state { return true } else { return false } }()
    [outboundField, returnField].forEach { $0.isEnabled = !loading }
    tripTypeControl.isEnabled = !loading

    switch state {
    case .idle:
      activityIndicator.stopAnimating()
      errorLabel.isHidden = true
      updateSubmitEnabled()
    case .loading:
      activityIndicator.startAnimating()
      errorLabel.isHidden = true
      submitButton.isEnabled = false
    case .failed(let message):
      activityIndicator.stopAnimating()
      errorLabel.text = message
      errorLabel.isHidden = false
      updateSubmitEnabled()
    }
  }

  // MARK: - Builders

  private func makeFlightGroup(title: String, field: UITextField, datePicker: UIDatePicker) -> UIStackView {
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
    titleLabel.textColor = .secondaryLabel

    let dateLabel = UILabel()
    dateLabel.text = "날짜"
    dateLabel.font = .systemFont(ofSize: 17)
    dateLabel.setContentHuggingPriority(.required, for: .horizontal)

    let dateRow = UIStackView(arrangedSubviews: [dateLabel, datePicker])
    dateRow.axis = .horizontal
    dateRow.spacing = 12
    dateRow.alignment = .center

    let group = UIStackView(arrangedSubviews: [titleLabel, field, dateRow])
    group.axis = .vertical
    group.spacing = 8
    return group
  }

  private static func makeField(placeholder: String) -> UITextField {
    let field = UITextField()
    field.placeholder = placeholder
    field.borderStyle = .roundedRect
    field.autocapitalizationType = .allCharacters
    field.autocorrectionType = .no
    field.clearButtonMode = .whileEditing
    field.returnKeyType = .search
    field.font = .systemFont(ofSize: 17)
    field.translatesAutoresizingMaskIntoConstraints = false
    return field
  }

  private static func makeDatePicker() -> UIDatePicker {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.preferredDatePickerStyle = .compact
    picker.translatesAutoresizingMaskIntoConstraints = false
    return picker
  }
}
