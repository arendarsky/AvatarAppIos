//
//MARK:  NotificationsVC.swift
//  AvatarAppIos
//
//  Created by Владислав on 11.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    //MARK:- Properties
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var sessionNotificationLabel: UILabel!
    
    var people = [Notification]()
    var cachedProfileImages: [UIImage?] = Array(repeating: nil, count: 100)
    var index = 0
    
    //MARK:- Lifecycle
    ///
    ///
    
    //MARK:- • Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        
        self.configureCustomNavBar()
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        reloadNotifications()
    }
    
    //MARK:- • Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureRefreshControl()
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile from Notifications" {
            let vc = segue.destination as! ProfileViewController
            vc.isPublic = true
            vc.userData.id = people[index].id
            vc.userData.name = people[index].name
            vc.userData.description = people[index].description
            if let img = cachedProfileImages[index] { vc.cachedProfileImage = img }
        }
    }
    
    //MARK:- Reload Notifications
    private func reloadNotifications(number: Int = 100, skip: Int = 0) {
        Profile.getNotifications(number: number, skip: skip) { (serverResult) in
            self.notificationsTableView.refreshControl?.endRefreshing()
            
            switch serverResult {
                //MARK:- Error Handling
            case .error(let error):
                print("Error: \(error)")
                if self.people.count == 0 {
                    self.sessionNotificationLabel.showNotification(.serverError)
                }
            case .results(let users):
                guard users.count > 0 else {
                    self.sessionNotificationLabel.showNotification(.zeroNotifications)
                    return
                }
                self.sessionNotificationLabel.isHidden = true
                self.people = users.reversed()
                self.cachedProfileImages = Array(repeating: nil, count: 100)
                self.loadAllProfileImages(for: self.people)
                self.notificationsTableView.reloadData()
            }
        }
    }
    
    //MARK:- Handle Refresh Control
    @objc private func handleRefreshControl() {
        //Refreshing Data
        reloadNotifications()

        /// Refresh control is being dismissed at the end of reloading the items
//        DispatchQueue.main.async {
//            self.notificationsTableView.refreshControl?.endRefreshing()
//        }
    }

}

//MARK:- Extensions
///
extension NotificationsVC {
    
    //MARK:- Configure Refresh Control
    func configureRefreshControl () {
        notificationsTableView.refreshControl?.endRefreshing()
        notificationsTableView.refreshControl = nil
        notificationsTableView.refreshControl = UIRefreshControl()
        notificationsTableView.refreshControl?.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        notificationsTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    //MARK:- Load Profile Photo
    func loadProfileImage(for user: Notification, index: Int) {
        guard let imageName = user.profilePhoto else {
            //print("no profile photo")
            return
        }
        Profile.getProfileImage(name: imageName) { (result) in
            switch result {
            case.error(let error):
                print(error)
            case.results(let image):
                self.cachedProfileImages[index] = image
                if let cell = self.notificationsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationCell {
                    cell.profileImageView.image = image
                }
            }
        }
    }
    
    //MARK:- Load All Profile Images
    func loadAllProfileImages(for users: [Notification]) {
        for (i, user) in users.enumerated() {
            loadProfileImage(for: user, index: i)
        }
    }
}

//MARK:- Table View Data Source & Delegate
extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notification Cell", for: indexPath) as! NotificationCell
        
        cell.nameLabel.text = people[indexPath.row].name
        cell.commentLabel.text = "Хочет увидеть тебя в финале XCE FACTOR 2020."
        cell.profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        if let image = cachedProfileImages[indexPath.row] {
            cell.profileImageView.image = image
        } else { loadProfileImage(for: people[indexPath.row], index: indexPath.row) }
                
        return cell
    }
      
    //MARK:- Did Select Row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Profile from Notifications", sender: nil)
        //showFeatureNotAvailableNowAlert(title: "Скоро здесь будет переход к профилю", message: "А пока ничего - ждите апдейт", shouldAddCancelButton: false, handler: nil)
        //action
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- Editing Table View
    /// not using now
    /*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Удалить"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //send request about the deleted notification
            people.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            if tableView.indexPathsForVisibleRows?.count == 0 {
                sessionNotificationLabel.showNotification(.zeroNotifications)
            }
        }
    }
    */
    
}


//MARK:- Tab Bar Delegate
extension NotificationsVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            self.notificationsTableView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}
