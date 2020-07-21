//
//  ViewController.swift
//  Copyright © 2020 tim@duckett.de. All rights reserved.
//

import UIKit


class SupplementalView: UICollectionReusableView {

    static let reuse = "sreuse"

    enum Kind {
        static let top = "top"
        static let bottom = "bottom"
    }

    enum Style {
        case top
        case bottom
    }

    let view = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemPink
        view.backgroundColor = .systemGray
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: widthAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureStyle(_ style: Style) {
    }
}


class ViewController: UIViewController {

    enum Section {
        case main
    }

    @IBOutlet var collectionView: UICollectionView!

    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil

    let items = [0, 1]

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(SupplementalView.self, forSupplementaryViewOfKind: SupplementalView.Kind.top, withReuseIdentifier: SupplementalView.reuse)
        collectionView.register(SupplementalView.self, forSupplementaryViewOfKind: SupplementalView.Kind.bottom, withReuseIdentifier: SupplementalView.reuse)

        configureLayout()
        configureCollectionView()

        updateData(items: items, withAnimation: false)
    }
}

extension ViewController {

    func configureLayout() {
        // we are gonna do two groups here to mimic sweet 16
        let numberOfCells: CGFloat = 2

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/numberOfCells))
        var groups = [NSCollectionLayoutGroup]()

        for _ in 0..<2 {
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
        let topSupplementalItem = NSCollectionLayoutSupplementaryItem(layoutSize: suppleSize, elementKind: SupplementalView.Kind.top, containerAnchor: NSCollectionLayoutAnchor(edges: .top), itemAnchor: NSCollectionLayoutAnchor(edges: .top))
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
                let style = str == SupplementalView.Kind.top ? SupplementalView.Style.top : SupplementalView.Style.bottom
                thing.configureStyle(style)
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
