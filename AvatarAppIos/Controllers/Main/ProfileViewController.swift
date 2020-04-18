//
//MARK:  ProfileViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import MobileCoreServices
import NVActivityIndicatorView

class ProfileViewController: UIViewController {

    //MARK:- Properties
    var isPublic = false
    var isEditProfileDataMode = false
    var isAppearingAfterUpload = false
    var isEditingVideoInterval = false
    var videosData = [Video]()
    var newVideo = Video()
    var userData = UserProfile()
    var cachedProfileImage: UIImage?
    var newImagePicked = false
    let symbolLimit = 150
    var cancelEditButton = UIBarButtonItem()
    var activityIndicatorBarItem = UIActivityIndicatorView()
    var loadingIndicatorFullScreen = NVActivityIndicatorView(frame: CGRect(), type: .circleStrokeSpin, color: .purple, padding: 8.0)

    @IBOutlet weak var scrollView: ProfileScrollView!
    
    @IBOutlet var optionsButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameEditField: UITextField!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var likesDescriptionLabel: UILabel!
    
    @IBOutlet weak var descriptionHeader: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionPlaceholder: UILabel!
    @IBOutlet weak var symbolCounter: UILabel!
    
    @IBOutlet weak var addNewVideoButton: UIButton!
    
    @IBOutlet weak var videosHeader: UILabel!
    @IBOutlet weak var videosContainer: UIView!
    @IBOutlet var videoViews: [ProfileVideoView]!
    @IBOutlet weak var zeroVideosLabel: UILabel!
    
    //MARK:- Profile VC Lifecycle
    ///
    ///
    
    //MARK:- • Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK:- color of back button for the NEXT vc
        navigationItem.backBarButtonItem?.tintColor = .white
        handlePossibleSoundError()
        self.configureCustomNavBar()
        loadingIndicatorFullScreen.enableCentered(in: view)
        
        configureViews()
        updateViewsData(newData: userData)
        updateData(isPublic: isPublic)
    }
    
    //MARK:- • Will Appear
    override func viewWillAppear(_ animated: Bool) {
        if isAppearingAfterUpload {
            updateData(isPublic: isPublic)
            isAppearingAfterUpload = false
        } else if isEditingVideoInterval {
            loadingIndicatorFullScreen.stopAnimating()
            isEditingVideoInterval = false
        }
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        configureRefrechControl()
        self.tabBarController?.delegate = self
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK:- Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Add Video from Profile":
            let vc = segue.destination as! VideoPickVC
            vc.isProfileInitiated = true
        case "Upload/Edit Video from Profile":
            let vc = segue.destination as! VideoUploadVC
            vc.video = newVideo
            vc.isProfileDirectly = true
            vc.isEditingVideoInterval = self.isEditingVideoInterval
            vc.navigationItem.title = self.isEditingVideoInterval ? "Изм. фрагмента" : "Выбор фрагмента"
        default:
            break
        }
    }
    
    //MARK:- Options/Save Button Pressed
    @IBAction func optionsButtonPressed(_ sender: Any) {
        if !isEditProfileDataMode {
            showOptionsAlert(
                //MARK:- Edit Account Button
                editHandler: { (action) in
                    self.enableEditMode()
                    self.descriptionTextView.becomeFirstResponder()
            },
                //MARK:- Settings Button
                settingsHandler: { (action) in
                    self.performSegue(withIdentifier: "Show Settings", sender: nil)
            },
                //MARK:- Exit Account Button
                quitHandler: { (action) in
                    self.confirmActionAlert(title: "Выйти из аккаунта?", message: "Это завершит текущую сессию пользователя") { (action) in
                        Defaults.clearUserData()
                        self.setApplicationRootVC(storyboardID: "WelcomeScreenNavBar")
                    }
            })
            
        } else {
            //MARK:- Edit Mode
            guard descriptionTextView.text.count <= symbolLimit else {
                showIncorrectUserInputAlert(title: "Описание слишком длинное", message: "")
                return
            }
            guard let nameText = nameEditField.text, nameText.count != 0 else {
                showIncorrectUserInputAlert(title: "Имя не может быть пустым", message: "")
                return
            }
            let image = profileImageView.image

            activityIndicatorBarItem.enableInNavBar(of: self.navigationItem)
            cancelEditButton.isEnabled = false
            
            uploadDescription(description: descriptionTextView.text) {
                self.uploadName(name: nameText)
            }
            uploadImage(image: image)
        }
    }
    
    //MARK:- Cancel Button Pressed
    @objc func cancelButtonPressed(_ sender: Any) {
        cancelEditing()
    }
    
    //MARK:- Edit Profile Image Button Pressed
    @IBAction func editImageButtonPressed(_ sender: Any) {
        showMediaPickAlert(mediaTypes: [kUTTypeImage], delegate: self, allowsEditing: true)
    }
    
    //MARK:- UIButton Highlighted
    @IBAction func buttonHighlighted(_ sender: UIButton) {
        sender.scaleIn()
    }
    
    //MARK:- UIButton Released
    @IBAction func buttonReleased(_ sender: UIButton) {
        sender.scaleOut()
    }
    
    //MARK:- Add New Video Button Pressed
    @IBAction func addNewVideoButtonPressed(_ sender: UIButton) {
        sender.scaleOut()
        showMediaPickAlert(mediaTypes: [kUTTypeMovie], delegate: self, allowsEditing: false, title: "Добавьте новое видео")
        //performSegue(withIdentifier: "Add Video from Profile", sender: sender)
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
        scrollView.refreshControl = nil
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.systemPurple.withAlphaComponent(0.8)
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
    }
    
    //MARK:- Handle Refresh Control
    @objc private func handleRefreshControl() {
        //Refreshing Data
        disableEditMode()
        updateData(isPublic: isPublic)
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            //self.nameLabel.text = self.userData.name
            self.activityIndicatorBarItem.disableInNavBar(of: self.navigationItem, replaceWithButton: self.optionsButton)
            //self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK:- >>> Update Profile Data <<<
    func updateData(isPublic: Bool) {
        //loadingIndicatorFullScreen.enableCentered(in: view)
        var id: Int? = nil
        if isPublic { id = self.userData.id }
        Profile.getData(id: id) { (serverResult) in
            //self.loadingIndicatorFullScreen.stopAnimating()
            self.scrollView.refreshControl?.endRefreshing()
            
            switch serverResult {
            case .error(let error):
                print(error)
            case .results(let profileData):
                DispatchQueue.main.async {
                    self.updateViewsData(newData: profileData)
                }
                
                //MARK:- Get Profile Image
                if let profileImageName = profileData.profilePhoto {
                    self.profileImageView.setProfileImage(named: profileImageName) { (image) in
                        self.cachedProfileImage = image
                    }
                }

                //MARK:- Configure Videos Info
                guard let videos = profileData.videos else {
                    return
                }
                print(videos)
         
                self.videosData = []
                for video in videos {
                    self.videosData.append(video.translatedToVideoType())
                }
                self.matchVideosToViews(videosData: self.videosData, isPublic: self.isPublic)
                
            }
            self.loadingIndicatorFullScreen.stopAnimating()
        }
    }
    
    //MARK:- Match Videos to Video Views
    func matchVideosToViews(videosData: [Video], isPublic: Bool) {
        videosHeader.isHidden = false
        videosContainer.isHidden = false
        addNewVideoButton.isHidden = false
        videoViews[0].isHidden = true
        
        var start = 1
        if videosData.count == 4 || isPublic {
            addNewVideoButton.isHidden = true
            videoViews[0].isHidden = false
            start = 0
        }
        if videosData.count == 0 && isPublic {
            zeroVideosLabel.isHidden = false
        } else {
            zeroVideosLabel.isHidden = true
        }
        
        for i in start..<4 {
            if isPublic {
                videoViews[i].optionsButton.isHidden = true
            }
            ///dataIndex is used for videosData ONLY
            let dataIndex = start == 0 ? i : i-1
            
            videoViews[i].delegate = self
            videoViews[i].index = i
            if dataIndex >= videosData.count {
                videoViews[i].isHidden = true
            } else {
                videoViews[i].isHidden = false
                if videoViews[i].video.name != videosData[dataIndex].name || videoViews[i].thumbnailImageView.image == nil {
                    videoViews[i].thumbnailImageView.image = nil
                    videoViews[i].loadingIndicator.startAnimating()
                }
                videoViews[i].video = videosData[dataIndex]
                //MARK:- Cache Video
                cacheVideoAndGetPreviewImage(at: i)
                //self.loadVideoPreviewImage(at: i)
                //}
                videoViews[i].notificationLabel.isHidden = true
                if videosData[dataIndex].isActive {
                    videoViews[i].notificationLabel.isHidden = false
                    videoViews[i].notificationLabel.text = "В кастинге"
                }
                if !(videosData[dataIndex].isApproved ?? false) {
                    videoViews[i].notificationLabel.isHidden = false
                    videoViews[i].notificationLabel.text = "На модерации"
                }
            }
            
        }
    }
    
}

//MARK:- ==== ProfileVC Extensions
///
extension ProfileViewController {
    ///
    //MARK:- Configure Views
    ///
    private func configureViews() {

        //MARK:- • General
        nameEditField.isHidden = true
        nameEditField.addPadding(.both(6.0))
        nameEditField.borderColorV = UIColor.white.withAlphaComponent(0.7)
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        editImageButton.layer.cornerRadius = editImageButton.frame.width / 2
        descriptionTextView.borderWidthV = 0
        descriptionTextView.borderColorV = UIColor.white.withAlphaComponent(0.7)
        //descriptionTextView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0)
        descriptionTextView.text = ""
        //descriptionTextView.isHidden = true
        descriptionTextView.delegate = self
        
        videosContainer.isHidden = true
        videosHeader.isHidden = true
        addNewVideoButton.addGradient(
            firstColor: UIColor(red: 0.879, green: 0.048, blue: 0.864, alpha: 0.3),
            secondColor: UIColor(red: 0.667, green: 0.239, blue: 0.984, alpha: 0.3),
            transform: CGAffineTransform(a: 1, b: 0, c: 0, d: 38.94, tx: 0, ty: -18.97)
        )
        addNewVideoButton.backgroundColor = .black
        
        //MARK:- • For Public Profile
        if isPublic {
            optionsButton.isEnabled = false
            optionsButton.tintColor = .clear
            
            likesNumberLabel.isHidden = true
            likesDescriptionLabel.isHidden = true

            NSLayoutConstraint.activate([
                descriptionHeader.topAnchor.constraint(equalTo: likesNumberLabel.topAnchor)
            ])
        //MARK:- • For Private Profile
        } else {
            videoViews[0].isHidden = true
            addNewVideoButton.isHidden = false
            navigationItem.title = "Мой профиль"
            
            optionsButton.isEnabled = true
            optionsButton.tintColor = .white
            //MARK:- Setting Cached Data at Load
            userData.name = Globals.user.name
            userData.description = Globals.user.description
            userData.likesNumber = Globals.user.likesNumber
        }
        //self.configureCustomNavBar()
        
    }
    
    //MARK:- Cache Video and Get Preview Image
    /**Tries to cache video at specified index with time limit of 10 seconds
     
     If caching is unsuccessful,
     loads preview image directly from url
     and makes a second try to cache video
     in the background with default limit.
    */
    private func cacheVideoAndGetPreviewImage(at index: Int) {
        CacheManager.shared.getFileWith(fileUrl: videoViews[index].video.url, specifiedTimeout: 10) { (result) in
            self.videoViews[index].loadingIndicator.stopAnimating()
            
            switch result {
            case.failure(let sessionError):
                self.loadVideoPreviewImage(at: index)
                //MARK:- Second Try Caching
                print("Error Caching Profile video at index \(index): \(sessionError)")
                if !self.isPublic {
                    print("Continue caching in background ...")
                    CacheManager.shared.getFileWith(fileUrl: self.videoViews[index].video.url) { (result) in
                        switch result {
                        case.failure(let error):
                            print("Repeated error caching video at index \(index): \(error).\nCache processing stopped.")
                        case.success(let url):
                            print("Caching video at index \(index) is successful after second try.")
                            self.videoViews[index].video.url = url
                            self.loadVideoPreviewImage(at: index)
                        }
                    }
                }
                
            case.success(let cachedUrl):
                self.videoViews[index].video.url = cachedUrl
                self.loadVideoPreviewImage(at: index)
            }
        }
    }
    
    //MARK:- Load Video Preview Image
    func loadVideoPreviewImage(at index: Int) {
        //if self.videoViews[index].thumbnailImageView.image == nil {
        VideoHelper.createVideoThumbnail(from: self.videoViews[index].video.url, timestamp: CMTime(seconds: self.videoViews[index].video.startTime, preferredTimescale: 1000)) { (image) in
            self.videoViews[index].loadingIndicator.stopAnimating()
            if image != nil {
                self.videoViews[index].thumbnailImageView.image = image
            }
        }
        //}
    }
    
    //MARK:- Update Views Data
    private func updateViewsData(newData: UserProfile) {
        self.userData.id = newData.id
        self.userData = newData
        self.nameLabel.text = newData.name
        if !isPublic {
            Globals.user.videosCount = userData.videos?.count ?? 0
        }
        if let likesNumber = newData.likesNumber {
            self.likesNumberLabel.text = likesNumber.formattedToLikes()
        }
        if let description = newData.description {
            self.descriptionTextView.text = description
            self.descriptionTextView.isHidden = false
            self.descriptionPlaceholder.isHidden = description.count > 0
        } else {
            self.descriptionTextView.text = ""
        }
        if let img = cachedProfileImage { profileImageView.image = img }
    }
    
    //MARK:- Count Non-Hidden Video Views
    private func nonHiddenVideoViews() -> Int {
        var res = 0
        for videoView in videoViews {
            if !videoView.isHidden {
                res += 1
            }
        }
        return res
    }
    
    
    //MARK:- Show Options Alert
    private func showOptionsAlert(editHandler: ((UIAlertAction) -> Void)?, settingsHandler: ((UIAlertAction) -> Void)?, quitHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        
        let editProfileButton = UIAlertAction(title: "Редактировать профиль", style: .default, handler: editHandler)
        let settingsButton = UIAlertAction(title: "Настройки", style: .default, handler: settingsHandler)
        let exitAccountButton = UIAlertAction(title: "Выйти из аккаунта", style: .destructive, handler: quitHandler)
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(editProfileButton)
        alert.addAction(settingsButton)
        alert.addAction(exitAccountButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Enable Edit Mode
    private func enableEditMode(){
        cancelEditButton = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        cancelEditButton.isEnabled = true
        cancelEditButton.tintColor = .white
        self.navigationItem.setLeftBarButton(cancelEditButton, animated: true)
        navigationItem.title = "Ред. профиля"
        
        optionsButton.image = UIImage(systemName: "checkmark.seal.fill")
        //optionsButton.title = "Сохранить"
        
        self.editImageButton.isHidden = false
        nameLabel.isHidden = true
        nameEditField.text = nameLabel.text
        nameEditField.isHidden = false
        nameEditField.isEnabled = true

        if #available(iOS 13.0, *) {
            descriptionTextView.backgroundColor = .systemFill
        } else {
            descriptionTextView.backgroundColor = .lightGray
        }
        descriptionTextView.borderWidthV = 1.0
        descriptionTextView.isEditable = true
        descriptionTextView.isSelectable = true
        symbolCounter.isHidden = false
        symbolCounter.text = "\(descriptionTextView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.text = "Расскажи о себе"
        self.isEditProfileDataMode = true
    }
    
    //MARK:- Disable Edit Mode
    private func disableEditMode() {
        self.navigationItem.setLeftBarButton(nil, animated: true)
        optionsButton.image = UIImage(systemName: "ellipsis.circle.fill")
        optionsButton.title = ""
        navigationItem.title = isPublic ? "Профиль" : "Мой профиль"
        navigationItem.setRightBarButton(optionsButton, animated: true)
        view.endEditing(true)
        
        self.editImageButton.isHidden = true
        nameEditField.isHidden = true
        nameEditField.isEnabled = false
        nameLabel.isHidden = false
        
        if #available(iOS 13.0, *) {
            self.descriptionTextView.backgroundColor = .systemBackground
        } else {
            self.descriptionTextView.backgroundColor = .white
        }
        self.descriptionTextView.borderWidthV = 0.0
        self.descriptionTextView.isEditable = false
        self.descriptionTextView.isSelectable = false
        symbolCounter.isHidden = true
        descriptionPlaceholder.text = "Нет описания"
        descriptionPlaceholder.isHidden = descriptionTextView.text.count != 0
        
        self.isEditProfileDataMode = false
    }
    
    //MARK:- Cancel Editing
    private func cancelEditing() {
        if !isEditProfileDataMode { return }
        descriptionTextView.text = userData.description
        profileImageView.image = cachedProfileImage ?? UIImage(systemName: "person.crop.circle.fill")
        disableEditMode()
    }
    
    //MARK:- Safely Finish Upload Tasks
    private func safelyFinishUploadTasks(handler: (() -> Void)?) {
        if let _ = handler {
            handler!()
        } else {
            self.activityIndicatorBarItem.disableInNavBar(of: self.navigationItem, replaceWithButton: self.optionsButton)
            self.disableEditMode()
        }
    }
    
    //MARK:- Upload Description
    func uploadDescription(description: String, handler: (() -> Void)? = nil) {
        Profile.setDescription(newDescription: descriptionTextView.text) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                self.cancelEditing()
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                    self.cancelEditing()
                } else {
                    self.safelyFinishUploadTasks(handler: handler)
                }
            }
            
        }
    }
    
    //MARK:- Upload Name
    func uploadName(name: String, handler: (() -> Void)? = nil) {
        guard name != nameLabel.text else {
            self.safelyFinishUploadTasks(handler: handler)
            return
        }
        
        Profile.setNewName(newName: name) { (serverResult) in
            switch serverResult {
            case .error(let error):
                print("Error: \(error)")
                self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое имя", message: "Проверьте подключение к интернету и попробуйте еще раз")
                self.cancelEditing()
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое имя", message: "Проверьте подключение к интернету и попробуйте еще раз")
                    self.cancelEditing()
                } else {
                    self.nameLabel.text = name
                    self.safelyFinishUploadTasks(handler: handler)
                }
            }
        }
    }
    
    //MARK:- Upload Image
    func uploadImage(image: UIImage?, handler: (() -> Void)? = nil){
        if cachedProfileImage == profileImageView.image || !newImagePicked {
            return
        } else {
            Profile.setNewImage(image: image) { (serverResult) in
                switch serverResult {
                case .error(let error):
                    print("Error: \(error)")
                    self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                    self.cancelEditing()
                case .results(let responseCode):
                    if responseCode != 200 {
                        self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                        self.cancelEditing()
                    } else {
                        self.safelyFinishUploadTasks(handler: handler)
                    }
                }
            }
        }
    }
    
    //MARK:- Delete Requset
    func deleteVideoRequest(videoName: String, handler: (() -> Void)?) {
        loadingIndicatorFullScreen.enableCentered(in: view)
        WebVideo.delete(videoName: videoName) { (isSuccess) in
            self.loadingIndicatorFullScreen.stopAnimating()
            if isSuccess {
                if Globals.user.videosCount == nil {
                    Globals.user.videosCount = 0
                } else {
                    Globals.user.videosCount! -= 1
                }
                handler?()
            } else {
                self.showErrorConnectingToServerAlert(title: "Не удалось удалить видео в данный момент", message: "Обновите экран профиля и попробуйте снова.")
            }
        }
    }
    
    //MARK:- Rearrange Video Views after deleting
    func rearrangeViewsAfterDelete(_ video: Video, at index: Int) {
        if video.isActive {
            self.videoViews[index].notificationLabel.isHidden = true
        }
        let leftViewsNumber = self.nonHiddenVideoViews()
        
        if leftViewsNumber == 4 {
            self.addNewVideoButton.isHidden = false
            self.videoViews.first?.isHidden = true
            //rearrangeViews() - make such method
            var i = index
            while i > 0 {
                self.videoViews[i].thumbnailImageView.image = self.videoViews[i-1].thumbnailImageView.image
                self.videoViews[i].video = self.videoViews[i-1].video
                self.videoViews[i].notificationLabel.isHidden = !self.videoViews[i-1].video.isActive
                if let isApproved = self.videoViews[i-1].video.isApproved {
                    if !isApproved {
                        self.videoViews[i].notificationLabel.isHidden = false
                        self.videoViews[i].notificationLabel.text = "На модерации"
                    }
                }
                if self.videoViews[i-1].video.isActive {
                    self.videoViews[i].notificationLabel.isHidden = false
                    self.videoViews[i].notificationLabel.text = "В кастинге"
                }
                i -= 1
            }
        } else {
            for i in index..<4 {
                if i < leftViewsNumber {
                    self.videoViews[i].thumbnailImageView.image = self.videoViews[i+1].thumbnailImageView.image
                    self.videoViews[i].video = self.videoViews[i+1].video
                    if let isApproved = self.videoViews[i+1].video.isApproved {
                        if !isApproved {
                            self.videoViews[i].notificationLabel.isHidden = false
                            self.videoViews[i].notificationLabel.text = "На модерации"
                        }
                    }
                    if self.videoViews[i+1].video.isActive {
                        self.videoViews[i].notificationLabel.isHidden = false
                        self.videoViews[i].notificationLabel.text = "В кастинге"
                    }
                } else {
                    self.videoViews[i].thumbnailImageView.image = nil
                    self.videoViews[i].isHidden = true
                }
            }
        }
        print("Number of videos left: \(leftViewsNumber)")
        //print("Video Views: \(self.videoViews)")
    }
    
}


//MARK:- Tab Bar Delegate
extension ProfileViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 3 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}


//MARK:- Profile Video View Delegate

extension ProfileViewController: ProfileVideoViewDelegate {

    //MARK:- Play Video Button Pressed
    func playButtonPressed(at index: Int, video: Video) {
        let fullScreenPlayer = AVPlayer(url: video.url!)
        let fullScreenPlayerVC = AVPlayerViewController()
        fullScreenPlayerVC.player = fullScreenPlayer
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 1000))
        fullScreenPlayerVC.player?.isMuted = Globals.isMuted
        fullScreenPlayerVC.player?.play()
        
        handlePossibleSoundError()
        present(fullScreenPlayerVC, animated: true, completion: nil)
    }
        
    //MARK:- Video Options Button Pressed
    func optionsButtonPressed(at index: Int, video: Video) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        //MARK:- Set Video Active
        let setActiveButton = UIAlertAction(title: "Отправить в кастинг", style: .default) { (action) in
            if !(video.isApproved ?? false) {
                self.showIncorrectUserInputAlert(title: "Видео пока нельзя отправить в кастинг",
                                                 message: "Оно ещё не прошло модерацию.")
            } else {
                //MARK:- Set Active Request
                self.loadingIndicatorFullScreen.enableCentered(in: self.view)
                WebVideo.setActive(videoName: video.name) { (isSuccess) in
                    self.loadingIndicatorFullScreen.stopAnimating()
                    if !isSuccess {
                        self.showErrorConnectingToServerAlert(title: "Не удалось связаться с сервером",
                                                              message: "Проверьте подключение к интернету и попробуйте еще раз.")
                    } else {
                        print("Setting Active video named: '\(video.name)'")
                        for videoView in self.videoViews {
                            videoView.notificationLabel.isHidden = (videoView.video.isApproved ?? false)
                        }
                        self.videoViews[index].notificationLabel.isHidden = false
                    }
                }
            }
        }
        
        //MARK:- Edit Video Interval
        let editIntervalButton = UIAlertAction(title: "Изменить фрагмент", style: .default) { (action) in
            self.loadingIndicatorFullScreen.enableCentered(in: self.view)
            self.newVideo = video
            self.isEditingVideoInterval = true
            self.performSegue(withIdentifier: "Upload/Edit Video from Profile", sender: nil)
        }

        //MARK:- Delete Video from Profile
        let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            self.confirmActionAlert(title: "Удалить видео?", message: "Вместе с этим видео из профиля также удалятся все лайки, полученные за него.") { (action) in
                self.deleteVideoRequest(videoName: video.name) {
                    self.rearrangeViewsAfterDelete(video, at: index)
                    self.updateData(isPublic: self.isPublic)
                }
            }
        }
        

        //MARK:- Present Video Options Alert
        alert.addAction(setActiveButton)
        alert.addAction(editIntervalButton)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        present(alert, animated: true, completion: nil)
    }
    
}


//MARK:- Image Picker Delegate
extension ProfileViewController: UINavigationControllerDelegate {}
extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeImage as String),
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dismiss(animated: true) {
                self.newImagePicked = true
                self.cachedProfileImage = self.profileImageView.image
                self.profileImageView.image = image
            }
        } else if
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            VideoHelper.encodeVideo(at: url) { (encodedUrl, error) in
                guard let resultUrl = encodedUrl else {
                    print("Error:", error ?? "unknown")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) { self.showVideoErrorAlert(with: "Произошла ошибка") }
                    }
                    return
                }
                self.newVideo.url = resultUrl
                let asset = AVAsset(url: resultUrl)
                self.newVideo.length = Double(asset.duration.value) / Double(asset.duration.timescale)
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "Upload/Edit Video from Profile", sender: nil)
                    }
                }
            }
        } else { return }
        
    }
}


//MARK:- Text View Delegate
extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.count <= symbolLimit {
            textView.borderColorV = UIColor.white.withAlphaComponent(0.7)
            if #available(iOS 13.0, *) {
                symbolCounter.textColor = .placeholderText
            } else {
                symbolCounter.textColor = .lightGray
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        symbolCounter.text = "\(textView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.isHidden = textView.text.count != 0
        if textView.text.count > symbolLimit {
            textView.borderColorV = .systemRed
            symbolCounter.textColor = .systemRed
        } else {
            textView.borderColorV = UIColor.white.withAlphaComponent(0.7)
            if #available(iOS 13.0, *) {
                symbolCounter.textColor = .placeholderText
            } else {
                symbolCounter.textColor = .lightGray
            }
        }
    }

}
