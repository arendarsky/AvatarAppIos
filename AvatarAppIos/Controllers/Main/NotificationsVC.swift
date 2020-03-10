//
//  NotificationsVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 11.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    //MARK:- Properties
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var zeroNotificationsLabel: UILabel!
    
    var people = ["Кое-кто", "Некто", "Кто-то"]
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        configureRefreshControl()
    }
    
    //MARK:- Configure Refresh Control
    func configureRefreshControl () {
        notificationsTableView.refreshControl = UIRefreshControl()
        notificationsTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    //MARK:- Handle Updates
    @objc func handleRefreshControl() {
        //Refreshing Data
        people = ["Кое-кто", "Некто", "Кто-то"]

        // Dismiss the refresh control.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //MARK:- ❗️Update Simulation. Don't forget to remove asyncAfter❗️
            self.notificationsTableView.reloadData()
            if self.notificationsTableView.indexPathsForVisibleRows?.count != 0 {
                self.zeroNotificationsLabel.isHidden = true
            } else {
                self.zeroNotificationsLabel.isHidden = false
            }
            self.notificationsTableView.refreshControl?.endRefreshing()
        }
    }

}

//MARK:- Table View Delegate & Data Source
extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notification Cell", for: indexPath)
        
        cell.textLabel?.text = people[indexPath.row]
        cell.detailTextLabel?.text = "Хочет видеть тебя."
        cell.imageView?.image = UIImage(named: "profileimg32.jpg")
        
        cell.imageView!.layer.cornerRadius = cell.imageView!.frame.width / 2
        
        return cell
    }
      
    //MARK:- Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFeatureNotAvailableNowAlert(title: "Скоро здесь будет переход к профилю", message: "А пока ничего - ждите апдейт", shouldAddCancelButton: false, handler: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK:- Editing Table View
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //send request about the deleted notification
            people.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            if tableView.indexPathsForVisibleRows?.count == 0 {
                zeroNotificationsLabel.isHidden = false
            }
        }
    }
    
}
