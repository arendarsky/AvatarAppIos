//
//MARK:  ProfileViewController.swift
//  AvatarAppIos
//
//  Created by Владислав on 15.03.2020.
//  Copyright © 2020 Владислав. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import MobileCoreServices
import NVActivityIndicatorView

class ProfileViewController: UIViewController {

    //MARK:- Properties
    var isPublic = false
    var isEditMode = false
    var isAppearingAfterUpload = false
    var videosData = [Video]()
    var userData = UserProfile()
    var cachedProfileImage: UIImage?
    var newImagePicked = false
    let symbolLimit = 150
    var cancelEditButton = UIBarButtonItem()
    var activityIndicatorBarItem = UIActivityIndicatorView()
    var loadingIndicatorFullScreen = NVActivityIndicatorView(frame: CGRect(),
                                                             type: .circleStrokeSpin,
                                                             color: .purple,
                                                             padding: 8.0)

    @IBOutlet weak var scrollView: UIScrollView!
    
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
        updateData(isPublic: isPublic)
        configureViews()
        self.configureCustomNavBar()
    }
    
    //MARK:- • Will Appear
    override func viewWillAppear(_ animated: Bool) {
        if isAppearingAfterUpload {
            updateData(isPublic: isPublic)
        }
    }
    
    //MARK:- • Did Appear
    override func viewDidAppear(_ animated: Bool) {
        configureRefrechControl()
        self.tabBarController?.delegate = self
    }
    
    //Hide the keyboard by touching somewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Add Video from Profile":
            let vc = segue.destination as! VideoPickVC
            vc.shouldHideViews = true
        default:
            break
        }
    }
    
    //MARK:- Options/Save Button Pressed
    @IBAction func optionsButtonPressed(_ sender: Any) {
        if !isEditMode {
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
                self.showExitAccountAlert { (action) in
                    Defaults.clearUserData()
                    let vc = self.storyboard?.instantiateViewController(identifier: "WelcomeScreenNavBar")
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
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
        descriptionTextView.text = userData.description
        profileImageView.image = cachedProfileImage ?? UIImage(systemName: "person.crop.circle.fill")
        disableEditMode()
    }
    
    //MARK:- Edit Profile Image Button Pressed
    @IBAction func editImageButtonPressed(_ sender: Any) {
        showMediaPickAlert(mediaTypes: [kUTTypeImage], delegate: self, allowsEditing: true)
    }
    
    //MARK:- Add New Video Button Pressed
    @IBAction func addNewVideoButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "Add Video from Profile", sender: sender)
    }
    
    //MARK:- Configure Refresh Control
    private func configureRefrechControl() {
        scrollView.refreshControl = nil
        let refreshControl = UIRefreshControl()
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
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK:- >>> Update Profile Data <<<
    func updateData(isPublic: Bool) {
        loadingIndicatorFullScreen.enableCentered(in: view)
        var id: Int? = nil
        if isPublic {
            id = self.userData.id
        }
        Profile.getData(id: id) { (serverResult) in
            self.loadingIndicatorFullScreen.stopAnimating()
            
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
                guard let videos = profileData.videos
                else {
                    return
                }
                print(videos)
         
                self.videosData = []
                for video in videos {
                    self.videosData.append(video.translateToVideoType())
                }
                print(self.videosData)

                self.matchVideosToViews(videosData: self.videosData, isPublic: self.isPublic)
                
            }
        }
    }
    
    //MARK:- Match Videos to Video Views
    func matchVideosToViews(videosData: [Video], isPublic: Bool) {
        videosHeader.isHidden = false
        videosContainer.isHidden = false
        
        var start = 1
        if videosData.count == 4 || isPublic {
            self.addNewVideoButton.isHidden = true
            self.videoViews[0].isHidden = false
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
            let dataIndex = start == 0 ? i : i-1
            self.videoViews[i].delegate = self
            self.videoViews[i].index = i
            if dataIndex >= videosData.count {
                self.videoViews[i].isHidden = true
            } else {
                self.videoViews[i].isHidden = false
                if self.videoViews[i].video.name != videosData[dataIndex].name || self.videoViews[i].thumbnailImageView.image == nil {
                    self.videoViews[i].thumbnailImageView.image = nil
                    //MARK:- Get Video Thumbnail
                    VideoHelper.createVideoThumbnailFromUrl(
                        videoUrl: videosData[dataIndex].url,
                        //seconds: self.videoViews[i].video.startTime
                        timestamp: CMTime(seconds: self.videoViews[i].video.startTime, preferredTimescale: 100)) { (image) in
                            self.videoViews[i].thumbnailImageView.image = image
                            self.videoViews[i].thumbnailImageView.contentMode = .scaleAspectFill
                    }
                }
                self.videoViews[i].video = videosData[dataIndex]
                self.videoViews[i].notificationLabel.isHidden = true
                if videosData[dataIndex].isActive {
                    self.videoViews[i].notificationLabel.isHidden = false
                    self.videoViews[i].notificationLabel.text = "В кастинге"
                }
                if !(videosData[dataIndex].isApproved ?? false) {
                    self.videoViews[i].notificationLabel.isHidden = false
                    self.videoViews[i].notificationLabel.text = "На модерации"
                }
            }
            
        }
    }
    
}

//MARK:- Configurations
private extension ProfileViewController {
    private func configureViews() {

        //MARK:- • General
        nameEditField.isHidden = true
        nameEditField.addPadding(.both(6.0))
        nameEditField.borderColorV = UIColor.white.withAlphaComponent(0.7)
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        editImageButton.layer.cornerRadius = editImageButton.frame.width / 2
        descriptionTextView.borderWidthV = 0
        descriptionTextView.borderColorV = UIColor.white.withAlphaComponent(0.7)
        descriptionTextView.isHidden = true
        descriptionTextView.delegate = self
        
        videosContainer.isHidden = true
        videosHeader.isHidden = true
        addNewVideoButton.configureHighlightedColors(color: .darkGray, alpha: 0.8)
        
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
        }
        
    }
    
    private func updateViewsData(newData: UserProfile) {
        self.userData = newData
        self.nameLabel.text = newData.name
        Globals.user.videosCount = userData.videos?.count ?? 0
        if let likes = newData.likesNumber {
            self.likesNumberLabel.text = "♥ \(likes)"
        }
        if let description = newData.description {
            self.descriptionTextView.text = description
            self.descriptionTextView.isHidden = false
            self.descriptionPlaceholder.isHidden = true
        } else {
            self.descriptionTextView.text = ""
        }
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

        descriptionTextView.borderWidthV = 1.0
        descriptionTextView.backgroundColor = .systemFill
        descriptionTextView.isEditable = true
        descriptionTextView.isSelectable = true
        symbolCounter.isHidden = false
        symbolCounter.text = "\(descriptionTextView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.text = "Расскажи о себе"
        self.isEditMode = true
    }
    
    //MARK:- Disable Edit Mode
    private func disableEditMode() {
        self.navigationItem.setLeftBarButton(nil, animated: true)
        optionsButton.image = UIImage(systemName: "ellipsis.circle.fill")
        optionsButton.title = ""
        navigationItem.title = isPublic ? "Профиль" : "Мой профиль"
        
        self.editImageButton.isHidden = true
        nameEditField.isHidden = true
        nameEditField.isEnabled = false
        nameLabel.isHidden = false
        
        self.descriptionTextView.borderWidthV = 0.0
        self.descriptionTextView.backgroundColor = .systemBackground
        self.descriptionTextView.isEditable = false
        self.descriptionTextView.isSelectable = false
        symbolCounter.isHidden = true
        descriptionPlaceholder.text = "Нет описания"
        descriptionPlaceholder.isHidden = descriptionTextView.text.count != 0
        self.isEditMode = false
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
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое описание", message: "Попробуйте еще раз.")
                    
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
            case .results(let responseCode):
                if responseCode != 200 {
                    self.showErrorConnectingToServerAlert(title: "Не удалось сохранить новое имя", message: "Проверьте подключение к интернету и попробуйте еще раз")
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
                case .results(let responseCode):
                    if responseCode != 200 {
                        self.showErrorConnectingToServerAlert(title: "Не удалось загрузить фото", message: "Обновите экран профиля и попробуйте еще раз")
                    } else {
                        self.safelyFinishUploadTasks(handler: handler)
                    }
                }
            }
        }
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
        fullScreenPlayerVC.player?.seek(to: CMTime(seconds: video.startTime, preferredTimescale: 600))
        fullScreenPlayerVC.player?.isMuted = Globals.isMuted
        fullScreenPlayerVC.player?.play()
        
        present(fullScreenPlayerVC, animated: true, completion: nil)
    }
        
    //MARK:- Video Options Button Pressed
    func optionsButtonPressed(at index: Int, video: Video) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .white
        
        //MARK:- Set Video Active
        let setActiveButton = UIAlertAction(title: "Отправить в кастинг", style: .default) { (action) in
            //set active method
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
                                                              message: "Обновите экран профиля и попробуйте еще раз.")
                    } else {
                        print("Setting Active video named: '\(video.name)'")
                        for videoView in self.videoViews {
                            videoView.notificationLabel.isHidden = videoView.video.isActive
                        }
                        self.videoViews[index].notificationLabel.isHidden = false
                    }
                }
            }
        }
        
        //MARK:- Delete Video from Profile
        let deleteButton = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
            //delete method

            if video.isActive {
                self.videoViews[index].notificationLabel.isHidden = true
            }
            let leftViewsNumber = self.nonHiddenVideoViews()
            
            //MARK:- Rearranging Video Views:
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
            
            //MARK:- Delete Requset
            WebVideo.delete(videoName: video.name) { (isSuccess) in
                if isSuccess {
                    if Globals.user.videosCount == nil {
                        Globals.user.videosCount = 0
                    } else {
                        Globals.user.videosCount! -= 1
                    }
                } else {
                    self.showErrorConnectingToServerAlert(title: "Не удалось удалить видео в данный момент", message: "Обновите экран профиля и попробуйте снова.")
                }
            }
        }
        
        let cnclBtn = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        //MARK:- Present Video Options Alert
        alert.addAction(setActiveButton)
        alert.addAction(deleteButton)
        alert.addAction(cnclBtn)
        present(alert, animated: true, completion: nil)
    }
    
}


//MARK:- Image Picker Delegate
extension ProfileViewController: UINavigationControllerDelegate {}
extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeImage as String),
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        else { return }
        
        dismiss(animated: true) {
            self.newImagePicked = true
            self.cachedProfileImage = self.profileImageView.image
            self.profileImageView.image = image
        }
        
    }
}


//MARK:- Text View Delegate
extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        //can change here e.g. border color
    }
    
    func textViewDidChange(_ textView: UITextView) {
        symbolCounter.text = "\(textView.text.count)/\(symbolLimit)"
        descriptionPlaceholder.isHidden = textView.text.count != 0
        if textView.text.count > symbolLimit {
            textView.borderColorV = .systemRed
            symbolCounter.textColor = .systemRed
        } else {
            textView.borderColorV = UIColor.white.withAlphaComponent(0.7)
            symbolCounter.textColor = .placeholderText
        }
    }

}
