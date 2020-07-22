//
//  ViewController.swift
//  Copyright © 2020 tim@duckett.de. All rights reserved.
//

import UIKit


class LineView: UIView {

    let horizontal = UIView()
    let vertical = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        horizontal.translatesAutoresizingMaskIntoConstraints = false
        horizontal.backgroundColor = .systemGray3
        vertical.translatesAutoresizingMaskIntoConstraints = false
        vertical.backgroundColor = .systemGray3

        addSubview(horizontal)
        addSubview(vertical)

        NSLayoutConstraint.activate([
            horizontal.heightAnchor.constraint(equalToConstant: 1),
            horizontal.centerYAnchor.constraint(equalTo: centerYAnchor),
            horizontal.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontal.trailingAnchor.constraint(equalTo: centerXAnchor),
            vertical.widthAnchor.constraint(equalToConstant: 1),
            vertical.centerXAnchor.constraint(equalTo: centerXAnchor),
            vertical.topAnchor.constraint(equalTo: centerYAnchor),
            vertical.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SupplementalView: UICollectionReusableView {

    static let reuse = "sreuse"

    enum Kind: String {
        case second = "second"
        case sweet16 = "sweet16"
        case elite8 = "elite8"

        var count: Int {
            switch self {
            case .second: return 8
            case .sweet16: return 4
            case .elite8: return 2
            }
        }
    }

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemPink
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        for _ in 1...Kind.second.count {
            let view = LineView()
            view.backgroundColor = .systemPink
            stackView.addArrangedSubview(view)
        }

        stride(from: 0, to: stackView.arrangedSubviews.count, by: 2).compactMap { stackView.arrangedSubviews[$0] }.forEach { $0.transform = CGAffineTransform.identity }
        stride(from: 1, to: stackView.arrangedSubviews.count, by: 2).compactMap { stackView.arrangedSubviews[$0] }.forEach { $0.transform = CGAffineTransform(scaleX: 1, y: -1) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithElementKind(_ kind: Kind?) {
        guard let kind = kind else { stackView.arrangedSubviews.forEach { $0.isHidden = true }; return }

        let subviews = stackView.arrangedSubviews
        subviews.prefix(kind.count).forEach { $0.isHidden = false }
        subviews.suffix(subviews.count - kind.count).forEach { $0.isHidden = true }
    }
}


class ViewController: UIViewController {

    enum Section {
        case main
    }

    enum Constant {
        static let test = SupplementalView.Kind.second
    }

    @IBOutlet var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    let items = Array<Int>(0...Constant.test.count)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(SupplementalView.self, forSupplementaryViewOfKind: SupplementalView.Kind.second.rawValue, withReuseIdentifier: SupplementalView.reuse)
        collectionView.register(SupplementalView.self, forSupplementaryViewOfKind: SupplementalView.Kind.sweet16.rawValue, withReuseIdentifier: SupplementalView.reuse)
        collectionView.register(SupplementalView.self, forSupplementaryViewOfKind: SupplementalView.Kind.elite8.rawValue, withReuseIdentifier: SupplementalView.reuse)

        configureLayout()
        configureCollectionView()

        updateData(items: items, withAnimation: false)
    }
}

extension ViewController {

    func configureLayout() {
        let cellCount = Constant.test.count / 2
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/CGFloat(cellCount)))
        var groups = [NSCollectionLayoutGroup]()

        for _ in 0..<cellCount {
            let firstGroup = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { (env) -> [NSCollectionLayoutGroupCustomItem] in
                let containerFrame = CGRect(origin: .zero, size: env.container.contentSize)
                var frame = CGRect(origin: .zero, size: CGSize(width: env.container.contentSize.width, height: 44))
                frame.origin = CGPoint(x: containerFrame.midX - (frame.size.width / 2), y: containerFrame.midY - (frame.size.height / 2))

                let item = NSCollectionLayoutGroupCustomItem(frame: frame)
                return [item]
            }

            groups.append(firstGroup)
        }

        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: groups)
        let suppleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let topSupplementalItem = NSCollectionLayoutSupplementaryItem(layoutSize: suppleSize, elementKind: Constant.test.rawValue, containerAnchor: NSCollectionLayoutAnchor(edges: .top), itemAnchor: NSCollectionLayoutAnchor(edges: .top))
        topSupplementalItem.zIndex = -1
        group.supplementaryItems = [topSupplementalItem]

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        collectionView.collectionViewLayout = layout
    }

    func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCell", for: indexPath) as UICollectionViewCell

            guard let cellLabel = cell.viewWithTag(1000) as? UILabel else {
                fatalError("Can't access label")
            }

            cellLabel.text = "Cell \(identifier)"

            return cell
        })

        dataSource.supplementaryViewProvider = { (cv, str, indexPath) -> UICollectionReusableView? in
            let thing = cv.dequeueReusableSupplementaryView(ofKind: str, withReuseIdentifier: SupplementalView.reuse, for: indexPath)

            if let thing = thing as? SupplementalView {
                let style = SupplementalView.Kind(rawValue: str)
                thing.configureWithElementKind(style)
            }

            return thing
        }
    }

    func updateData(items: Array<Int>, withAnimation: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: withAnimation, completion: nil)
    }
}
