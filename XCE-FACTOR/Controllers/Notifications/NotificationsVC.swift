//
//  AvatarAppIos
//
//  Created by Владислав on 11.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Amplitude

final class NotificationsVC: XceFactorViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var sessionNotificationLabel: UILabel!
    @IBOutlet weak var notificationsNumberLabel: UILabel!
    //@IBOutlet weak var footerView: UIView!
    //@IBOutlet weak var loadingMoreIndicator: NVActivityIndicatorView!

    // MARK: - Private UI Properties

    private var loadingIndicator = NVActivityIndicatorView(frame: CGRect(),
                                                   type: .circleStrokeSpin,
                                                   color: .systemPurple,
                                                   padding: 8.0)

    private let supplementaryColor = UIColor.lightGray.withAlphaComponent(0.7)

    // MARK: - Private Properties

    private var people = [Notification]()

    private var requestedNumberOfNotifications = 200
    private var index = 0

    private var shouldReloadImages = false
    private var isFirstLoad = true

        private lazy var cachedProfileImages = [UIImage?]()// = Array(repeating: nil, count: requestedNumberOfNotifications)

    // TODO: Инициализирвоать в билдере, при переписи на MVP поправить
    private let profileManager = ProfileServicesManager(networkClient: NetworkClient())
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomNavBar()
        configureRefreshControl()
        configureViews()
        loadingIndicator.enableCentered(in: view)
        reloadNotifications(with: requestedNumberOfNotifications)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstLoad {
            isFirstLoad = false
        } else {
            reloadNotifications(with: requestedNumberOfNotifications)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.delegate = self
        navigationController?.tabBarItem.badgeValue = nil
        
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldReloadImages = false
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile from Notifications" {
            let vc = segue.destination as! ProfileViewController
            vc.isPublic = true
            vc.userData.id = people[index].id
            vc.userData.name = people[index].name ?? ""
            vc.userData.description = people[index].description
            if let img = cachedProfileImages[index] { vc.cachedProfileImage = img }
        }
    }

    @IBAction func infoButtonPressed(_ sender: Any) {
        presentInfoViewController(withHeader: navigationItem.title, infoAbout: .notifications)
    }
    
    // MARK: - Actions

    ///Refreshing Data
    @objc private func handleRefreshControl() {
        shouldReloadImages = true
        reloadNotifications(with: requestedNumberOfNotifications)

        /// Refresh control is being dismissed at the end of reloading the items
//        DispatchQueue.main.async {
//            self.notificationsTableView.refreshControl?.endRefreshing()
//        }
    }
}

// MARK: - Network Layer

private extension NotificationsVC {
    func loadMoreNotifications(_ number: Int) {
        guard people.count > 0 else { return }
        
        profileManager.getNotifications(number: number, skip: people.count) { result in
            //self.loadingMoreIndicator.stopAnimating()
            
            switch result {
            case .failure(let error):
                print("Error loading more notifications: \(error)")
            // TODO: Handle Error
            case .success(let newUsers):
                guard newUsers.count > 0 else { return }
                //                print("New items: \(newUsers)")
                self.cachedProfileImages += Array(repeating: nil, count: newUsers.count)
                self.people += newUsers
                //                print("Updated items count: \(self.people.count)")
                //                print("Updated items: \(self.people)")
                self.loadNewProfileImages(for: self.people)
                self.notificationsTableView.reloadData()
            }
        }
    }

    func reloadNotifications(with number: Int) {
        profileManager.getNotifications(number: number, skip: 0) { result in
            self.notificationsTableView.refreshControl?.endRefreshing()
            self.loadingIndicator.stopAnimating()
            self.sessionNotificationLabel.isHidden = true

            switch result {
            case .failure(let error):
                print("Error reloading notifications: \(error)")
                if self.people.count == 0 {
                    self.sessionNotificationLabel.showNotification(.serverError)
                }
            case .success(let users):
                guard users.count > 0 else {
                    self.sessionNotificationLabel.showNotification(.zeroNotifications)
                    return
                }
                if users.count != self.people.count || self.shouldReloadImages {
                    self.cachedProfileImages = Array(repeating: nil, count: self.requestedNumberOfNotifications)
                    self.shouldReloadImages = false

                    if let profileNav = self.tabBarController?.viewControllers?.last as? UINavigationController,
                        let profileVC = profileNav.viewControllers.first as? ProfileViewController {
                        profileVC.shouldUpdateData = true
                    }
                }
                self.people = users
                self.loadAllProfileImages(for: self.people)
                
                self.notificationsNumberLabel.text = "Последние \(self.people.count)"
                self.notificationsNumberLabel.isHidden = self.people.count < 10
                
                self.notificationsTableView.reloadData()
            }
        }
    }
}

// MARK: - Private Methods

private extension NotificationsVC {
    
    func configureRefreshControl () {
        notificationsTableView.refreshControl = UIRefreshControl()
        notificationsTableView.refreshControl?.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        notificationsTableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    func configureViews() {
        notificationsNumberLabel.textColor = supplementaryColor
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        //notificationsTableView.prefetchDataSource = self
    }

    func nameWithDate(of user: Notification) -> NSMutableAttributedString {
        let attrString = NSMutableAttributedString(string: user.name ?? "",
                                                   attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
                                                                NSAttributedString.Key.foregroundColor: UIColor.label])
        if let date = user.date {
            let dateString = NSMutableAttributedString(string: " • " + date.formattedTimeIntervalToNow(),
                                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0),
                                                                    NSAttributedString.Key.foregroundColor: supplementaryColor])
            attrString.append(dateString)
        }
        
        return attrString
    }

    func loadProfileImage(for user: Notification, index: Int) {
        guard let imageName = user.profilePhoto else {
            clearImage()
            return
        }

        Profile.getProfileImage(name: imageName) { result in
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

    func clearImage() {
        cachedProfileImages[index] = nil
        if let cell = notificationsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationCell {
            cell.profileImageView.image = nil
        }
    }

    func loadAllProfileImages(for users: [Notification]) {
        for (i, user) in users.enumerated() {
            loadProfileImage(for: user, index: i)
        }
    }

    func loadNewProfileImages(for users: [Notification]) {
        for (i, user) in users.enumerated() {
            if cachedProfileImages[i] == nil {
                loadProfileImage(for: user, index: i)
            }
        }
    }
}

// MARK: - Table View Data Source & Delegate

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notification Cell",
                                                 for: indexPath) as! NotificationCell

        //cell.nameLabel.text = people[indexPath.row].name
        ///show the date of notification ⬇️
        cell.nameLabel.attributedText = nameWithDate(of: people[indexPath.row])
        
        cell.commentLabel.text = "Хочет увидеть тебя в финале XCE FACTOR 2020!"
        //cell.commentLabel.text = people[indexPath.row].date.formattedTimeIntervalToNow()
        cell.profileImageView.image = IconsManager.getIcon(.personCircleFill)
        if let image = cachedProfileImages[indexPath.row] {
            cell.profileImageView.image = image
        } else { loadProfileImage(for: people[indexPath.row], index: indexPath.row) }
                
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Profile from Notifications", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        Amplitude.instance()?.logEvent("notificationprofile_button_tapped")
    }

    // TODO: Нужно ли удалить или оставить
    /// not using now /*, UITableViewDataSourcePrefetching*/
    /*
     func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        loadMoreNotifications(requestedNumberOfNotifications)
    }
    
    
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

//MARK: - UITabBarControllerDelegate

extension NotificationsVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            self.notificationsTableView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}
