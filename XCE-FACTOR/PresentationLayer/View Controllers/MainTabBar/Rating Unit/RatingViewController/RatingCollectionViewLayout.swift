//
//  RatingCollectionView.swift
//  XCE-FACTOR
//
//  Created by Владислав on 30.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension RatingViewController {

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let layoutKind = self.getRatingType(for: section) else { return nil }

            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSize,
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                            alignment: .top)
            
            switch layoutKind {
            case .finalists:
                let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
                let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
                topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
                let contentWidth = layoutEnvironment.container.effectiveContentSize.width
                let itemsCount = contentWidth > 350 ? 5 : 4
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: topItem, count: itemsCount)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            case .semifinalists:
                let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
                let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
                topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
                let contentWidth = layoutEnvironment.container.effectiveContentSize.width
                let itemsCount = contentWidth > 350 ? 5 : 4
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: topItem, count: itemsCount)

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [sectionHeader]

                return section
            /// Video Cells Layout
            case .topList:
                let ratingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                            heightDimension: .fractionalHeight(1.0))
                let ratingItem = NSCollectionLayoutItem(layoutSize: ratingItemSize)
                ratingItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
                
                let height = layoutEnvironment.container.effectiveContentSize.height
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: layoutKind.groupHeight(height: height))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [ratingItem])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
        }
        return layout
    }
}

