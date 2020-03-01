//
//  StarRatingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class StarRatingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingCollectionView.delegate = self
        self.ratingCollectionView.dataSource = self
    }

    @IBOutlet weak var ratingCollectionView: UICollectionView!
    //@IBOutlet weak var ratingType: UISegmentedControl!
    @IBAction func segmentedControlChanged(_ sender: Any) {
        type = type == 0 ? 1 : 0
        ratingCollectionView.reloadData()
    }
    
    var producersTop: [String] = Array(repeating: "Producer Person Name", count: 20)
    var starsTop: [String] = Array(repeating: "Star Person Name", count: 20)
    var type = 0
    
    
}

extension StarRatingViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch type {
        case 0:
            return starsTop.count
        case 1:
            return producersTop.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarView Rating Cell", for: indexPath) as! StarRatingCell
        
        switch type {
        case 0:
            cell.nameLabel.text = starsTop[indexPath.row]
            break
        case 1:
            cell.nameLabel.text = producersTop[indexPath.row]
            break
        default:
            break
        }
        cell.profileImageView.image = UIImage(named: "profileimg32.jpg")
        cell.positionLabel.text = String(indexPath.row + 1)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       switch kind {
         case UICollectionView.elementKindSectionHeader:
             guard
                 let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Star Rating Header", for: indexPath) as? StarHeaderView
                 else {
                     fatalError("Invalid view type")
             }
             //headerView.sectionHeader.text = "ТОП-20"
             //headerView.title.text = "Label"
             return headerView
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sRating Footer", for: indexPath)
            return footerView
       default:
         assert(false, "Invalid element type")
        return UICollectionReusableView()
       }
     }
}
