//
//MARK:  ProfileCollectionViewManaging.swift
//  XCE-FACTOR
//
//  Created by Владислав on 06.06.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

extension ProfileViewController {
    
    //MARK:- Configure Collection View
    func configureCollectionView() {
        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        profileCollectionView.collectionViewLayout = createLayout()
    }
    
    //MARK:- Create Layout
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let aspectRatio = CGFloat(9.0) / 16.0
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalWidth(aspectRatio / 2))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            let spacing: CGFloat = 10.0
            group.interItemSpacing = .fixed(spacing)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(400)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
            section.boundarySupplementaryItems = [sectionHeader]
            section.supplementariesFollowContentInsets = false

            return section
        }
        
        return layout
    }
        
}

//MARK:- Data Source & Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var number = 1
        if videosData.count < Globals.maxVideosAllowed && !isPublic {
            number = videosData.count + 1
        } else {
            number = videosData.count == 0 ? 1 : videosData.count
        }
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //profileUserInfo.videosHeaderLabel.isHidden = false
        if videosData.count == 0 {
            let addVideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddVideoCell", for: indexPath) as! AddVideoCell
            addVideoCell.setViews(accordingTo: isPublic)
            addVideoCell.delegate = self
            return addVideoCell
        }
        var index = 1
        if isPublic || videosData.count == Globals.maxVideosAllowed {
            index = indexPath.row
        } else {
            index = indexPath.row - 1
        }
        switch indexPath.row {
        case 0:
            if isPublic || videosData.count == Globals.maxVideosAllowed {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileVideoCell", for: indexPath) as! ProfileVideoCell
                cell.configureVideoCell(at: indexPath.row, with: videosData[indexPath.row], isPublic: isPublic, delegate: self)
                
                return cell
                
            } else {
                let addCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddVideoCell", for: indexPath) as! AddVideoCell
                addCell.delegate = self
                
                return addCell
            }
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileVideoCell", for: indexPath) as! ProfileVideoCell
            cell.configureVideoCell(at: index, with: videosData[index], isPublic: isPublic, delegate: self)
            
            return cell
        }
    }
    
    //MARK:- Supplementary View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Invalid element kind")
        }
        
        guard let userInfoView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileUserInfoView", for: indexPath) as? ProfileUserInfoView else {
            fatalError("Invalid view type")
        }

        profileUserInfo = userInfoView
        profileUserInfo.delegate = self
        
        if isFirstLoad {
            isFirstLoad = false
            configureViews()
            updateData(isPublic: isPublic)
        }
        if shouldUpdateSection {
            updateViewsData(newData: userData)
            shouldUpdateSection = false
        }

        return profileUserInfo
    }
    
    
    //MARK:- Context Menu Configuration
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProfileVideoCell,
            let videoView = cell.videoView else { return nil }
        let identifier = "\(indexPath.row)" as NSString
                
        return MenuManager.profileVideoMenuConfig(videoView: videoView, identifier: identifier)
    }
    
    //MARK:- Context Menu Preview Action
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let id = configuration.identifier as? String, let index = Int(id) else {
            print("Incorrect id for cell with context menu")
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProfileVideoCell, let videoView = cell.videoView else {
            print("no cell for such indexPath with context Menu")
            return
        }
        
        animator.addCompletion {
            videoView.delegate?.playButtonPressed(at: videoView.index, video: videoView.video)
        }
                        
    }
    
}
