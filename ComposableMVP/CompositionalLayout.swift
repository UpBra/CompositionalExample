//
//  CompositionalLayout.swift
//  Copyright © 2020 duckett.de. All rights reserved.
//

import UIKit


extension UICollectionViewCompositionalLayout {


    static var twoSections: UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = -20

        return UICollectionViewCompositionalLayout(sectionProvider: { (index, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)

            section.interGroupSpacing = CGFloat(-10 * (index+1))
            section.contentInsets = NSDirectionalEdgeInsets(top: CGFloat(-10 * (index+1)), leading: 0, bottom: 0, trailing: 0)

            return section
        }, configuration: config)
    }
}
