import Combine
import UIKit

private nonisolated enum TripCalendarSection: Hashable { case main }

final class TripCalendarViewController: UIViewController {

  private let viewModel: TripCalendarViewModel
  private var dataSource: UICollectionViewDiffableDataSource<TripCalendarSection, CalendarDay>!
  private var cancellables = Set<AnyCancellable>()

  private let monthLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let yearLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .regular)
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let prevButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let nextButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let weekdayStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.translatesAutoresizingMaskIntoConstraints = false
    ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].enumerated().forEach { index, title in
      let label = UILabel()
      label.text = title
      label.textAlignment = .center
      label.font = .systemFont(ofSize: 12, weight: .semibold)
      label.textColor = (index == 0) ? .systemRed : (index == 6 ? .systemBlue : .secondaryLabel)
      stack.addArrangedSubview(label)
    }
    return stack
  }()

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 4
    layout.minimumInteritemSpacing = 0
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .clear
    cv.isScrollEnabled = false
    cv.delegate = self
    cv.translatesAutoresizingMaskIntoConstraints = false
    return cv
  }()

  private let summaryLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    label.textColor = .label
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let flightLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .regular)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  init(viewModel: TripCalendarViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.title = viewModel.trip.destination.name
    summaryLabel.text = viewModel.summaryText
    flightLabel.text = viewModel.flightText
    setupViews()
    setupDataSource()
    bindViewModel()
  }

  private func setupDataSource() {
    let registration = UICollectionView.CellRegistration<CalendarDayCell, CalendarDay> { [weak self] cell, _, day in
      guard let self else { return }
      cell.configure(day: day, rangeState: viewModel.rangeState(for: day))
    }

    dataSource = UICollectionViewDiffableDataSource<TripCalendarSection, CalendarDay>(
      collectionView: collectionView
    ) { collectionView, indexPath, day in
      collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: day)
    }
  }

  private func applySnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<TripCalendarSection, CalendarDay>()
    snapshot.appendSections([.main])
    snapshot.appendItems(viewModel.days)
    dataSource.apply(snapshot, animatingDifferences: false)
  }

  private func bindViewModel() {
    viewModel.$days
      .sink { [weak self] _ in self?.applySnapshot() }
      .store(in: &cancellables)

    viewModel.monthTitle
      .sink { [weak self] title in self?.monthLabel.text = title }
      .store(in: &cancellables)

    viewModel.yearTitle
      .sink { [weak self] title in self?.yearLabel.text = title }
      .store(in: &cancellables)

    prevButton.eventPublisher(for: .touchUpInside)
      .sink { [weak self] _ in self?.viewModel.goToPreviousMonth() }
      .store(in: &cancellables)

    nextButton.eventPublisher(for: .touchUpInside)
      .sink { [weak self] _ in self?.viewModel.goToNextMonth() }
      .store(in: &cancellables)
  }

  private func setupViews() {
    let header = UIView()
    header.translatesAutoresizingMaskIntoConstraints = false
    header.addSubview(yearLabel)
    header.addSubview(monthLabel)
    header.addSubview(prevButton)
    header.addSubview(nextButton)

    view.addSubview(header)
    view.addSubview(weekdayStack)
    view.addSubview(collectionView)
    view.addSubview(summaryLabel)
    view.addSubview(flightLabel)

    let safe = view.safeAreaLayoutGuide

    NSLayoutConstraint.activate([
      header.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
      header.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
      header.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
      header.heightAnchor.constraint(equalToConstant: 56),

      yearLabel.topAnchor.constraint(equalTo: header.topAnchor),
      yearLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
      monthLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 2),
      monthLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),

      nextButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
      nextButton.trailingAnchor.constraint(equalTo: header.trailingAnchor),
      nextButton.widthAnchor.constraint(equalToConstant: 44),
      nextButton.heightAnchor.constraint(equalToConstant: 44),

      prevButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
      prevButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -8),
      prevButton.widthAnchor.constraint(equalToConstant: 44),
      prevButton.heightAnchor.constraint(equalToConstant: 44),

      weekdayStack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
      weekdayStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
      weekdayStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
      weekdayStack.heightAnchor.constraint(equalToConstant: 24),

      collectionView.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: 4),
      collectionView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
      collectionView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
      collectionView.heightAnchor.constraint(equalTo: collectionView.widthAnchor, multiplier: 6.0 / 7.0),

      summaryLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
      summaryLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
      summaryLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),

      flightLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 6),
      flightLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
      flightLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20)
    ])
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TripCalendarViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.bounds.width / 7
    return CGSize(width: width, height: width)
  }
}
