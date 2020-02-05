//
//  ProducerRatingViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 05.02.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class ProducerRatingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingTableView.delegate = self
        self.ratingTableView.dataSource = self
    }

    @IBOutlet weak var ratingTableView: UITableView!
    @IBOutlet weak var ratingType: UISegmentedControl!
    @IBAction func segmentedControlChanged(_ sender: Any) {
        self.ratingTableView.reloadData()
    }
    
    var producersTop: [String] = Array(repeating: "Producer Person Name", count: 20)
    var starsTop: [String] = Array(repeating: "Star Person Name", count: 20)
    
    
}

extension ProducerRatingViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ratingType.selectedSegmentIndex {
        case 0:
            return starsTop.count
        case 1:
            return producersTop.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProducerRatingCell
        switch ratingType.selectedSegmentIndex {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ТОП-20"
    }
    
    
}
