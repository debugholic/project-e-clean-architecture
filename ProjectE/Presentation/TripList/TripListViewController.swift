import Combine
import UIKit

private nonisolated enum TripListSection: Hashable { case main }

final class TripListViewController: UIViewController {

  private let viewModel: TripListViewModel
  private let calendar = Calendar.current
  private var dataSource: UITableViewDiffableDataSource<TripListSection, Trip>!
  private var cancellables = Set<AnyCancellable>()

  /// 다음 화면 생성은 컴포지션 루트가 주입한다 (목록은 의존성 출처를 모른다).
  var makeAddReservation: (@MainActor () -> UIViewController)?
  var makeCalendar: (@MainActor (Trip) -> UIViewController)?

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "아직 일정이 없어요.\n+ 버튼으로 편명을 입력해 일정을 추가하세요."
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.font = .systemFont(ofSize: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  init(viewModel: TripListViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    navigationItem.title = "내 일정"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(didTapAdd)
    )
    setupViews()
    setupDataSource()
    bindViewModel()
  }

  private func setupViews() {
    view.addSubview(tableView)
    view.addSubview(emptyLabel)
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripCell")

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
      emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
    ])
  }

  private func setupDataSource() {
    dataSource = UITableViewDiffableDataSource<TripListSection, Trip>(
      tableView: tableView
    ) { [calendar] tableView, indexPath, trip in
      let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
      var content = cell.defaultContentConfiguration()
      content.text = TripFormatter.summary(trip, calendar: calendar)
      content.secondaryText = TripFormatter.listFlightText(trip)
      cell.contentConfiguration = content
      cell.accessoryType = .disclosureIndicator
      return cell
    }
  }

  private func bindViewModel() {
    viewModel.$trips
      .sink { [weak self] trips in
        guard let self else { return }
        var snapshot = NSDiffableDataSourceSnapshot<TripListSection, Trip>()
        snapshot.appendSections([.main])
        snapshot.appendItems(trips)
        dataSource.apply(snapshot, animatingDifferences: true)
        emptyLabel.isHidden = !trips.isEmpty
      }
      .store(in: &cancellables)
  }

  @objc private func didTapAdd() {
    guard let viewController = makeAddReservation?() else { return }
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - UITableViewDelegate

extension TripListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let trip = dataSource.itemIdentifier(for: indexPath),
          let viewController = makeCalendar?(trip) else { return }
    navigationController?.pushViewController(viewController, animated: true)
  }

  func tableView(
    _ tableView: UITableView,
    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    guard let trip = dataSource.itemIdentifier(for: indexPath) else { return nil }
    let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
      self?.viewModel.delete(trip)
      completion(true)
    }
    return UISwipeActionsConfiguration(actions: [delete])
  }
}
