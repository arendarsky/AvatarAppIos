//
//  RatingCollectionView.swift
//  XCE-FACTOR
//
//  Created by Владислав on 30.05.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

// MARK: - UI Collection View Data Source

extension RatingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var numberOfSections = 1

//        if !finalists.isEmpty {
//            numberOfSections += 1
//        }

        if !semifinalists.isEmpty {
            numberOfSections += 1
        }

        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionKind = SectionKind(rawValue: section) else { fatalError("Undefined section") }
        switch sectionKind {
//        case .finalists:
//            return finalists.count
        case .semifinalists:
            return semifinalists.count
        case .topList:
            return starsTop.count
        }
    }
}

//MARK: - UI Collection View Delegate

extension RatingViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionKind = SectionKind(rawValue: indexPath.section)
              else { fatalError("Undefined section") }

        switch sectionKind {
//        case .finalists:
//            let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell",
//                                                               for: indexPath) as! StoriesCell
//            let name = semifinalists[indexPath.row].name
//            let likes = semifinalists[indexPath.row].likesNumber
//            let image = cachedSemifinalistsImages[indexPath.row]
//
//            storyCell.setupCell(to: .likes(likes), image: image, name: name)
//
//            if image == nil {
//                loadProfileImage(for: semifinalists[indexPath.row], indexPath: indexPath)
//            }
//
//            return storyCell
        case .semifinalists:
            let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell",
                                                               for: indexPath) as! StoriesCell
            let name = semifinalists[indexPath.row].name
            let likes = semifinalists[indexPath.row].likesNumber
            let image = cachedSemifinalistsImages[indexPath.row]

            storyCell.setupCell(to: .likes(likes), image: image, name: name)
        
            if image == nil {
                loadProfileImage(for: semifinalists[indexPath.row], indexPath: indexPath)
            }

            return storyCell
        case .topList:
            let item = starsTop[indexPath.row]
            let likes = item.likesNumber ?? 0
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RatingCell",
                                                          for: indexPath) as! RatingCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.configureVideoView(self)
            cell.profileImageView.image = IconsManager.getIcon(.personCircleFill)

            if let image = cachedProfileImages[indexPath.row] {
                cell.profileImageView.image = image
            } else {
                loadProfileImage(for: item, indexPath: indexPath)
            }
            
            cell.nameLabel.text = item.name
            cell.positionLabel.text = "#\(indexPath.row + 1)"
            cell.likesLabel.text = likes.formattedToLikes(.fullForm)
            cell.descriptionLabel.text = item.description
            
            cell.updatePlayPauseButtonImage()
            cell.playPauseButton.isHidden = false
            cell.muteButton.isHidden = !Globals.isMuted
            cell.updateControls()
            
            /// Configuring Video
            cacheVideo(for: item, index: indexPath.row)
            cell.configureVideoPlayer(user: item, cachedUrl: cachedVideoUrls[indexPath.row])
            
            return cell
        }
    }
    
    /// Did End Displaying Cell
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? RatingCell else { return }

        cell.pauseVideo()
        for visibleCell in ratingCollectionView.visibleCells {
            (visibleCell as? RatingCell)?.updateControls()
        }
    }
    
    /// Collection View Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
       case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RatingCollectionViewHeader", for: indexPath) as? RatingCollectionViewHeader,
                let sectionKind = SectionKind(rawValue: indexPath.section) else {
                    fatalError("Invalid view type or undefined section")
            }
            // .finalists:
            headerView.sectionTitleLabel.text = sectionKind == .semifinalists ? "Полуфиналисты" : "Топ-50"
            //headerView.numberLabel.isHidden = sectionKind != .semifinalists
            headerView.numberLabel.text = ""//sectionKind == .semifinalists ? "\(self.semifinalists.count)" : ""
            return headerView

       default:
            assert(false, "Invalid element type")
            return UICollectionReusableView()
        }
    }
    
    /// Did Select Item at Index Path
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cachedProfileImage: UIImage? = nil

        // TODO: Обработать если нет полуфиналистов, финалистов
        switch indexPath.section {
        case 0:
            let userProfile = semifinalists[indexPath.row].translatedToUserProfile()
            if let img = cachedSemifinalistsImages[indexPath.row] { cachedProfileImage = img }

            router.routeToProfileVC(for: userProfile, profileImage: cachedProfileImage)
        default: break
        }
    }
}

extension RatingViewController {

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let layoutKind = SectionKind(rawValue: sectionIndex) else { return nil }

            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSize,
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                            alignment: .top)
            
            switch layoutKind {
//            case .finalists:
//                let topItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
//                let topItem = NSCollectionLayoutItem(layoutSize: topItemSize)
//                topItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
//                
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
//                let contentWidth = layoutEnvironment.container.effectiveContentSize.width
//                let itemsCount = contentWidth > 350 ? 5 : 4
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: topItem, count: itemsCount)
//                
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .continuous
//                section.boundarySupplementaryItems = [sectionHeader]
//                
//                return section
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
