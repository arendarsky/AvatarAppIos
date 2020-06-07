//
//  RatingCollectionViewDelegate.swift
//  XCE-FACTOR
//
//  Created by Владислав on 30.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

//MARK:- Data Source
extension RatingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? semifinalists.count : starsTop.count
    }
}

//MARK:- Collection View Delegate
///
extension RatingViewController: UICollectionViewDelegate {
    
    //MARK:- Cell Configuration
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = SectionKind(rawValue: indexPath.section) else { fatalError("Undefined section") }
        switch sectionKind {
        //MARK:- Semifinalists' section
        case .semifinalists:
            let topCell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath) as! SemifinalistCell
            topCell.nameLabel.text = semifinalists[indexPath.row].name
            topCell.profileImageView.layer.cornerRadius = topCell.frame.width / 2
            topCell.profileImageView.image = IconsManager.getIcon(.personCircleFill)
            if let img = cachedSemifinalistsImages[indexPath.row] {
                topCell.profileImageView.image = img
            } else { loadProfileImage(for: semifinalists[indexPath.row], indexPath: indexPath)}

            return topCell
          
        //MARK:- TOP-50
        case .topList:
            let item = starsTop[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pRating Cell", for: indexPath) as! RatingCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.configureVideoView(self)
            cell.profileImageView.image = IconsManager.getIcon(.personCircleFill)
            if let image = cachedProfileImages[indexPath.row] {
                cell.profileImageView.image = image
            } else { loadProfileImage(for: item, indexPath: indexPath) }
            
            cell.nameLabel.text = item.name
            cell.positionLabel.text = "#\(indexPath.row + 1)"
            let likes = item.likesNumber ?? 0
            cell.likesLabel.text = likes.formattedToLikes(.fullForm)
            cell.descriptionLabel.text = item.description
            
            cell.updatePlayPauseButtonImage()
            cell.playPauseButton.isHidden = false
            //cell.replayButton.isHidden = true
            cell.muteButton.isHidden = !Globals.isMuted
            cell.updateControls()
            
            //MARK:- Configuring Video
            cacheVideo(for: item, index: indexPath.row)
            cell.configureVideoPlayer(user: item, cachedUrl: cachedVideoUrls[indexPath.row])
            //        }
            return cell
        }
    }
    
    //MARK:- Did End Displaying Cell
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let rCell = cell as? RatingCell else {
            return
        }
        rCell.pauseVideo()
        for visibleCell in ratingCollectionView.visibleCells {
            (visibleCell as? RatingCell)?.updateControls()
        }
    }
    
    //MARK: Collection View Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
       case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "pRating Header", for: indexPath) as? RatingCollectionViewHeader else {
                fatalError("Invalid view type")
            }
            headerView.sectionHeader.text = indexPath.section == 0 ? "Полуфиналисты" : "Топ-50"
            return headerView

       default:
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }
    
    //MARK:- Did Select Item at Index Path
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "Profile from Rating", sender: indexPath)
        }
    }
}

extension RatingViewController {
    //MARK:- Create Layout
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let layoutKind = SectionKind(rawValue: sectionIndex) else { return nil }
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(44)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            switch layoutKind {
            //MARK:- Top ortogonal cells layout
            case .semifinalists:
                let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                         heightDimension: .fractionalHeight(1.0))
                let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
                topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(80))
                let contentWidth = layoutEnvironment.container.effectiveContentSize.width
                let itemsCount = contentWidth > 350 ? 5 : 4
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: topItem, count: itemsCount)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            //MARK:- Video Cells Layout
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
    
    //MARK:- Section Kinds
    enum SectionKind: Int, CaseIterable {
        case semifinalists, topList
        
        func groupHeight(height: CGFloat) -> NSCollectionLayoutDimension {
            switch self {
            case .semifinalists:
                return .estimated(80.0)
            case .topList:
                return .fractionalHeight(height > 800 ? 0.9 : 0.925)
            }
        }
        
    }
}
