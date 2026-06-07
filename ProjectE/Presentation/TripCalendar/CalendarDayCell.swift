import UIKit

final class CalendarDayCell: UICollectionViewCell {

  enum RangeState {
    case none
    case start
    case middle
    case end
    case single
  }

  private var rangeState: RangeState = .none

  /// 여행 기간을 끊김 없이 잇는 연한색 밴드.
  private let highlightView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBlue.withAlphaComponent(0.22)
    view.isHidden = true
    return view
  }()

  private let dayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(highlightView)
    contentView.addSubview(dayLabel)

    NSLayoutConstraint.activate([
      dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    rangeState = .none
    highlightView.isHidden = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layoutHighlight()
  }

  private func layoutHighlight() {
    guard rangeState != .none else {
      highlightView.isHidden = true
      return
    }

    let width = contentView.bounds.width
    let height = contentView.bounds.height
    let diameter = min(width, height) - 8        // 양 끝 원의 지름
    let inset = (width - diameter) / 2
    let y = (height - diameter) / 2
    let radius = diameter / 2

    switch rangeState {
    case .none:
      return
    case .single:
      highlightView.frame = CGRect(x: inset, y: y, width: diameter, height: diameter)
      highlightView.layer.cornerRadius = radius
      highlightView.layer.maskedCorners = [
        .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner
      ]
    case .start:
      // 시작: 왼쪽은 둥글게, 오른쪽은 셀 끝까지 이어 다음 날과 연결.
      highlightView.frame = CGRect(x: inset, y: y, width: width - inset, height: diameter)
      highlightView.layer.cornerRadius = radius
      highlightView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    case .end:
      // 끝: 오른쪽은 둥글게, 왼쪽은 셀 시작까지 이어 이전 날과 연결.
      highlightView.frame = CGRect(x: 0, y: y, width: width - inset, height: diameter)
      highlightView.layer.cornerRadius = radius
      highlightView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    case .middle:
      highlightView.frame = CGRect(x: 0, y: y, width: width, height: diameter)
      highlightView.layer.cornerRadius = 0
    }
    highlightView.isHidden = false
  }

  func configure(day: CalendarDay, rangeState: RangeState) {
    self.rangeState = day.isInCurrentMonth ? rangeState : .none
    dayLabel.text = "\(day.dayNumber)"

    if !day.isInCurrentMonth {
      dayLabel.textColor = .tertiaryLabel
      dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
    } else {
      switch self.rangeState {
      case .start, .end, .single:
        dayLabel.textColor = .systemBlue
        dayLabel.font = .systemFont(ofSize: 16, weight: .bold)
      case .middle:
        dayLabel.textColor = .systemBlue
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
      case .none:
        dayLabel.textColor = day.isToday ? .systemBlue : .label
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
      }
    }

    setNeedsLayout()
  }
}
